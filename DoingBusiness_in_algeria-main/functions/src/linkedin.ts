/**
 * ════════════════════════════════════════════════════════════════════════
 *  LinkedIn article mirror — Cloud Functions
 * ════════════════════════════════════════════════════════════════════════
 *  Two callable endpoints:
 *
 *   1. previewLinkedInArticle(url)
 *        → { title, description, imageUrl, author }
 *        Fetches the LinkedIn post's public HTML, extracts Open Graph tags.
 *        Does NOT write to Firestore. Used by admin UI to show a preview
 *        before publishing.
 *
 *   2. createLinkedInArticle(url, categoryId?, overrides?)
 *        → { articleId }
 *        Re-fetches the preview server-side (anti-tampering), applies any
 *        admin overrides, writes to Firestore with source='linkedin'.
 *
 *  Security:
 *   - Both require request.auth.token.admin === true (set via Admin SDK)
 *   - App Check enforced
 *   - URL regex whitelist (only linkedin.com/posts|pulse|feed/update)
 *   - Rate-limit: 1 post per admin per minute
 *   - Duplicate detection by URL
 *   - Content caps: title ≤ 200 chars, description ≤ 5000 chars
 *
 *  Cost:
 *   - Cloud Functions Gen 2 / europe-west1
 *   - Average ~200ms per preview call (cheerio parse)
 *   - Firestore writes: 1 per publish
 *   - Negligible at expected volume (~50 posts/month)
 * ════════════════════════════════════════════════════════════════════════
 */

import * as admin from 'firebase-admin';
import { onCall, HttpsError, CallableRequest } from 'firebase-functions/v2/https';
import { setGlobalOptions } from 'firebase-functions/v2';
import axios from 'axios';
import * as cheerio from 'cheerio';

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// Region close to Algeria. Change if your Firestore is elsewhere.
setGlobalOptions({ region: 'europe-west1', maxInstances: 10 });

const db = admin.firestore();

// ───────────────────────────────────────────────────────────────────────
//  Constants
// ───────────────────────────────────────────────────────────────────────

const LINKEDIN_URL_REGEX =
  /^https:\/\/(www\.)?linkedin\.com\/(posts\/[^\s?#]+|pulse\/[^\s?#]+|feed\/update\/[^\s?#]+)/;

// Identifiable User-Agent — the "public OG tags" approach in the CHANGELOG is
// legally coherent only if we don't impersonate a browser. If LinkedIn chooses
// to block this UA one day, we'll learn about it and can evolve the strategy
// (official API, partnership) rather than silently bypassing their detection.
const USER_AGENT =
  'DoingBusinessBot/1.0 (+https://doingbusiness.grantthornton.dz)';

const MAX_TITLE_LEN = 200;
const MAX_DESCRIPTION_LEN = 5000;
const FETCH_TIMEOUT_MS = 10_000;
const MAX_CONTENT_LENGTH = 5 * 1024 * 1024; // 5 MB
const RATE_LIMIT_WINDOW_MS = 60_000; // 1 minute

// ───────────────────────────────────────────────────────────────────────
//  Types
// ───────────────────────────────────────────────────────────────────────

interface PreviewResult {
  title: string;
  description: string;
  imageUrl: string | null;
  author: string | null;
}

interface PreviewRequest {
  url: string;
}

interface CreateRequest {
  url: string;
  categoryId?: string;
  overrideTitle?: string;
  overrideDescription?: string;
  overrideImageUrl?: string;
}

// ───────────────────────────────────────────────────────────────────────
//  Helpers
// ───────────────────────────────────────────────────────────────────────

function assertAdmin(request: CallableRequest<unknown>): void {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must be signed in.');
  }
  if (request.auth.token.admin !== true) {
    throw new HttpsError(
      'permission-denied',
      'Admin privileges required. Contact your editor.'
    );
  }
}

function assertLinkedInUrl(url: unknown): asserts url is string {
  if (typeof url !== 'string' || url.length === 0) {
    throw new HttpsError('invalid-argument', 'URL is required.');
  }
  if (url.length > 500) {
    throw new HttpsError('invalid-argument', 'URL is too long.');
  }
  if (!LINKEDIN_URL_REGEX.test(url)) {
    throw new HttpsError(
      'invalid-argument',
      'Only LinkedIn URLs are accepted (posts, pulse articles, or feed updates).'
    );
  }
}

async function fetchLinkedInPreview(url: string): Promise<PreviewResult> {
  // SSRF hardening: manually follow up to 3 redirects and re-validate every
  // hop against LINKEDIN_URL_REGEX. Using axios' built-in `maxRedirects` would
  // follow the Location header anywhere — including `169.254.169.254/computeMetadata`
  // (GCP metadata service), `localhost:*`, or arbitrary 3rd parties.
  const MAX_HOPS = 3;
  let currentUrl = url;
  let html: string | null = null;

  for (let hop = 0; hop <= MAX_HOPS; hop++) {
    if (!LINKEDIN_URL_REGEX.test(currentUrl)) {
      throw new HttpsError(
        'invalid-argument',
        'Redirect target is not a LinkedIn URL — refusing to follow for SSRF safety.'
      );
    }

    let response;
    try {
      response = await axios.get<string>(currentUrl, {
        headers: {
          'User-Agent': USER_AGENT,
          Accept: 'text/html,application/xhtml+xml,application/xml;q=0.9',
          'Accept-Language': 'en-US,en;q=0.9,fr;q=0.8',
          'Cache-Control': 'no-cache',
        },
        timeout: FETCH_TIMEOUT_MS,
        maxContentLength: MAX_CONTENT_LENGTH,
        maxRedirects: 0,                       // we handle them ourselves
        validateStatus: (status) => status < 400 || (status >= 300 && status < 400),
      });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'unknown error';
      throw new HttpsError(
        'unavailable',
        `Could not fetch the LinkedIn page. It may be private, deleted, or blocked. (${message})`
      );
    }

    if (response.status >= 300 && response.status < 400) {
      const location = response.headers['location'];
      if (!location) {
        throw new HttpsError('unavailable', 'LinkedIn returned a redirect without a Location header.');
      }
      currentUrl = new URL(location, currentUrl).toString();
      continue;
    }

    html = response.data;
    break;
  }

  if (html === null) {
    throw new HttpsError(
      'unavailable',
      `LinkedIn sent too many redirects (>${MAX_HOPS}). Refusing for SSRF safety.`
    );
  }

  const $ = cheerio.load(html);

  const ogTitle = $('meta[property="og:title"]').attr('content') ?? '';
  const ogDescription = $('meta[property="og:description"]').attr('content') ?? '';
  const ogImage = $('meta[property="og:image"]').attr('content') ?? null;
  const ogAuthor =
    $('meta[property="article:author"]').attr('content') ??
    $('meta[name="author"]').attr('content') ??
    null;

  // Defensive: if LinkedIn served a login wall, og:title will contain "Sign in | LinkedIn".
  // Let the admin see the preview anyway and override manually.
  return {
    title: ogTitle.trim(),
    description: ogDescription.trim(),
    imageUrl: ogImage ? ogImage.trim() : null,
    author: ogAuthor ? ogAuthor.trim() : null,
  };
}

function sanitizeText(input: string | undefined, maxLen: number): string {
  if (!input) return '';
  return input.trim().slice(0, maxLen);
}

// ───────────────────────────────────────────────────────────────────────
//  Endpoint: previewLinkedInArticle
// ───────────────────────────────────────────────────────────────────────

export const previewLinkedInArticle = onCall<PreviewRequest, Promise<PreviewResult>>(
  { enforceAppCheck: true, cors: true },
  async (request) => {
    assertAdmin(request);
    assertLinkedInUrl(request.data.url);

    const preview = await fetchLinkedInPreview(request.data.url);
    return preview;
  }
);

// ───────────────────────────────────────────────────────────────────────
//  Endpoint: createLinkedInArticle
// ───────────────────────────────────────────────────────────────────────

export const createLinkedInArticle = onCall<CreateRequest, Promise<{ articleId: string }>>(
  { enforceAppCheck: true, cors: true },
  async (request) => {
    assertAdmin(request);
    assertLinkedInUrl(request.data.url);

    const uid = request.auth!.uid;
    const { url, categoryId, overrideTitle, overrideDescription, overrideImageUrl } =
      request.data;

    // ─── Rate limit: 1 post per admin per minute ──────────────────────
    const recent = await db
      .collection('Articles')
      .where('addedBy', '==', uid)
      .where(
        'addedAt',
        '>',
        admin.firestore.Timestamp.fromMillis(Date.now() - RATE_LIMIT_WINDOW_MS)
      )
      .limit(1)
      .get();

    if (!recent.empty) {
      throw new HttpsError(
        'resource-exhausted',
        'Please wait a minute before publishing another post.'
      );
    }

    // ─── Duplicate detection by URL ───────────────────────────────────
    const duplicate = await db
      .collection('Articles')
      .where('linkedinUrl', '==', url)
      .limit(1)
      .get();

    if (!duplicate.empty) {
      throw new HttpsError(
        'already-exists',
        'This LinkedIn post is already in the feed.'
      );
    }

    // ─── Re-fetch server-side to prevent tampering ────────────────────
    const preview = await fetchLinkedInPreview(url);

    // ─── Build article (admin overrides win over auto-extracted) ──────
    const article = {
      titre: sanitizeText(overrideTitle || preview.title, MAX_TITLE_LEN) || 'LinkedIn post',
      blog: sanitizeText(overrideDescription || preview.description, MAX_DESCRIPTION_LEN),
      image: sanitizeText(overrideImageUrl || preview.imageUrl || '', 2048),
      pdfLink: '',
      category: sanitizeText(categoryId, 64),

      // New fields for the mirroring feature:
      source: 'linkedin' as const,
      linkedinUrl: url,
      externalUrl: url,
      author: sanitizeText(preview.author ?? undefined, 120),
      addedBy: uid,
      addedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const docRef = await db.collection('Articles').add(article);

    return { articleId: docRef.id };
  }
);

// ───────────────────────────────────────────────────────────────────────
//  Optional: scheduled refresh (every 6h) — to re-fetch thumbnails that
//  may expire. Leave commented until you observe broken images in the app.
// ───────────────────────────────────────────────────────────────────────

// import { onSchedule } from 'firebase-functions/v2/scheduler';
//
// export const refreshLinkedInThumbnails = onSchedule(
//   { schedule: 'every 6 hours', timeZone: 'Africa/Algiers' },
//   async () => {
//     const snapshot = await db
//       .collection('Articles')
//       .where('source', '==', 'linkedin')
//       .limit(100)
//       .get();
//     for (const doc of snapshot.docs) {
//       const url = doc.data().linkedinUrl as string;
//       try {
//         const preview = await fetchLinkedInPreview(url);
//         await doc.ref.update({ image: preview.imageUrl ?? doc.data().image });
//       } catch (_) {
//         // swallow
//       }
//     }
//   }
// );
