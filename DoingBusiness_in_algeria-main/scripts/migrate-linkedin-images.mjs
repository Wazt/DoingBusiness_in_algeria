#!/usr/bin/env node
/**
 * migrate-linkedin-images.mjs — download LinkedIn OG images to Firebase
 * Storage and update each article's `image` field to the permanent URL.
 *
 * Why: LinkedIn's OG image URLs are signed CDN links that expire within
 * hours/days. Once expired, the app falls back to the purple gradient.
 * By hosting our own copy we get permanent URLs.
 *
 * For each article where source === 'linkedin':
 *   1. Re-fetch the LinkedIn post's fresh OG:image URL (the one in the
 *      DB has already expired by now).
 *   2. Download the image bytes.
 *   3. Upload to gs://<bucket>/articles/{articleId}.jpg with public read.
 *   4. Update the article doc's `image` field to the public https URL.
 *
 * Safe to re-run. Skips articles whose image already lives on our Storage.
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';
import axios from 'axios';
import * as cheerio from 'cheerio';

const sa = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(sa),
  storageBucket: 'doingbusinessbygrantthorntondz.firebasestorage.app',
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

const USER_AGENT =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

async function fetchFreshOgImage(postUrl) {
  const res = await axios.get(postUrl, {
    headers: { 'User-Agent': USER_AGENT, 'Accept-Language': 'en-US,en;q=0.9,fr;q=0.8' },
    timeout: 15000,
    maxRedirects: 3,
  });
  const $ = cheerio.load(res.data);
  return (
    $('meta[property="og:image"]').attr('content') ||
    $('meta[name="og:image"]').attr('content') ||
    ''
  );
}

async function downloadImage(url) {
  const res = await axios.get(url, {
    responseType: 'arraybuffer',
    headers: { 'User-Agent': USER_AGENT, Referer: 'https://www.linkedin.com/' },
    timeout: 20000,
    maxRedirects: 5,
  });
  return Buffer.from(res.data);
}

async function uploadToStorage(articleId, bytes, mime = 'image/jpeg') {
  const path = `articles/${articleId}.jpg`;
  const file = bucket.file(path);
  await file.save(bytes, {
    metadata: { contentType: mime, cacheControl: 'public, max-age=31536000, immutable' },
    resumable: false,
  });
  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${path}`;
}

async function main() {
  const snap = await db.collection('Articles').where('source', '==', 'linkedin').get();
  console.log(`\nProcessing ${snap.size} LinkedIn articles…\n`);

  let ok = 0, skip = 0, err = 0;
  for (const doc of snap.docs) {
    const data = doc.data();
    const tag = `[${doc.id.slice(0, 6)}]`;
    const title = String(data.titre || '').slice(0, 60);

    try {
      if (typeof data.image === 'string' && data.image.startsWith(`https://storage.googleapis.com/${bucket.name}/`)) {
        console.log(`${tag} SKIP already migrated: ${title}`);
        skip++;
        continue;
      }

      const postUrl = data.linkedinUrl || data.externalUrl;
      if (!postUrl) {
        console.log(`${tag} SKIP no source URL: ${title}`);
        skip++;
        continue;
      }

      const freshImageUrl = await fetchFreshOgImage(postUrl);
      if (!freshImageUrl) {
        console.log(`${tag} SKIP no og:image on post: ${title}`);
        skip++;
        continue;
      }

      const bytes = await downloadImage(freshImageUrl);
      const publicUrl = await uploadToStorage(doc.id, bytes);

      await doc.ref.update({ image: publicUrl });
      console.log(`${tag} ✓ (${(bytes.length / 1024).toFixed(0)} KB) ${title}`);
      ok++;

      await new Promise((r) => setTimeout(r, 800));
    } catch (e) {
      console.error(`${tag} ✗ ${title}`);
      console.error(`        ${e.message}`);
      err++;
    }
  }

  console.log(`\nDone. ${ok} migrated, ${skip} skipped, ${err} errors.\n`);
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
