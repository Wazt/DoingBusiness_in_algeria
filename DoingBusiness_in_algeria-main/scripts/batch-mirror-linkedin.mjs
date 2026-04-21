#!/usr/bin/env node
/**
 * batch-mirror-linkedin.mjs — one-off seeding script.
 *
 * Replicates the `createLinkedInArticle` Cloud Function (admin-side):
 *   1. Fetches each LinkedIn URL's public Open Graph tags (title, image, description, author)
 *   2. Writes an /Articles/{auto-id} doc with source='linkedin' + linkedinUrl + externalUrl
 *
 * Runs with the Firebase Admin SDK (bypasses Firestore rules + admin claim check),
 * which is appropriate for one-time staging seeding. The in-app wizard still goes
 * through the deployed Cloud Function for runtime use.
 *
 * Prereqs:
 *   - serviceAccountKey.json in this folder
 *   - npm install  (already done)
 *   - npm install axios cheerio  (run this once)
 *
 * Usage:
 *   node batch-mirror-linkedin.mjs
 *
 * Edit URLS array below to change what gets mirrored.
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';
import axios from 'axios';
import * as cheerio from 'cheerio';

const serviceAccount = JSON.parse(
  readFileSync('./serviceAccountKey.json', 'utf8')
);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const db = admin.firestore();

const EDITOR_EMAIL = 'editor@grantthornton.dz';

const URLS = [
  'https://www.linkedin.com/posts/grant-thornton-algeria_the-grant-thornton-era-activity-7452303356770852864-_WT2',
  'https://www.linkedin.com/posts/grant-thornton-algeria_newsletter-d%C3%A9p%C3%B4t-des-comptes-annuels-activity-7451992726566486016-1Rbs',
  'https://www.linkedin.com/posts/grant-thornton-algeria_outsourcing-et-innovation-des-processus-activity-7450464297551581185-oIwE',
  'https://www.linkedin.com/posts/grant-thornton-algeria_women-in-business-activity-7445440000487362560-g2_B',
  'https://www.linkedin.com/posts/grant-thornton-algeria_grantthornton-algeria-gobeyond-activity-7442864848851324928-dqSd',
  'https://www.linkedin.com/posts/grant-thornton-algeria_grantthornton-algaezrie-gobeyond-activity-7447968266335145984-DBrN',
  'https://www.linkedin.com/posts/grant-thornton-algeria_grantthornton-algeria-gtexplains-activity-7446858419283656704-HaBm',
  'https://www.linkedin.com/posts/grant-thornton-algeria_alerte-fiscale-activity-7439695734846955520-ZZeZ',
  'https://www.linkedin.com/posts/grant-thornton-algeria_point-fiscal-n03-activity-7435275779019694080-uKmm',
  'https://www.linkedin.com/posts/grant-thornton-algeria_point-fiscal-n02-activity-7429781812614172672-35k7',
  'https://www.linkedin.com/posts/grant-thornton-algeria_newsletter-cession-de-titres-aux-investisseurs-activity-7426915537126850560-e0lL',
  'https://www.linkedin.com/posts/grant-thornton-algeria_point-fiscal-lf-2026-activity-7426196706314141696-tZ68',
  'https://www.linkedin.com/posts/grant-thornton-algeria_la-loi-de-finances-2026-activity-7423010633543204864-kUK8',
  'https://www.linkedin.com/posts/grant-thornton-algeria_newsletter-d%C3%A9p%C3%B4t-des-comptes-annuels-activity-7421836741176864768-iBST',
  'https://www.linkedin.com/posts/grant-thornton-algeria_newsletter-r%C3%A9gime-des-travailleurs-%C3%A9trangers-activity-7418621548489711616-fwmJ',
  'https://www.linkedin.com/posts/grant-thornton-algeria_prorogation-des-d%C3%A9lais-de-d%C3%A9p%C3%B4t-des-d%C3%A9clarations-activity-7416185344531795968-K0xc',
  'https://www.linkedin.com/posts/grant-thornton-algeria_newsletter-protection-des-donn%C3%A9es-personnelles-activity-7415017182243487745-Iv2R',
];

const USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

async function fetchPreview(url) {
  const response = await axios.get(url, {
    headers: { 'User-Agent': USER_AGENT, 'Accept-Language': 'en-US,en;q=0.9,fr;q=0.8' },
    timeout: 15000,
    maxRedirects: 3,
  });
  const $ = cheerio.load(response.data);
  const og = (prop) => $(`meta[property="${prop}"]`).attr('content') || $(`meta[name="${prop}"]`).attr('content');
  return {
    title: og('og:title') || $('title').text() || 'LinkedIn post',
    description: og('og:description') || og('description') || '',
    imageUrl: og('og:image') || '',
    author: og('article:author') || og('og:article:author') || null,
  };
}

function clean(s, max) {
  if (!s) return '';
  return String(s).trim().slice(0, max);
}

async function main() {
  // Get editor UID for addedBy field
  const editor = await admin.auth().getUserByEmail(EDITOR_EMAIL).catch(() => null);
  if (!editor) {
    console.error(`✗ ${EDITOR_EMAIL} not found. Run seed-users.mjs first.`);
    process.exit(1);
  }

  console.log(`\nMirroring ${URLS.length} LinkedIn posts as ${EDITOR_EMAIL} (uid ${editor.uid})\n`);

  let ok = 0, dup = 0, err = 0;
  for (let i = 0; i < URLS.length; i++) {
    const url = URLS[i];
    const tag = `[${String(i + 1).padStart(2, ' ')}/${URLS.length}]`;
    try {
      // Duplicate check
      const existing = await db.collection('Articles').where('linkedinUrl', '==', url).limit(1).get();
      if (!existing.empty) {
        console.log(`${tag} SKIP duplicate: ${url.slice(0, 80)}`);
        dup++;
        continue;
      }

      const preview = await fetchPreview(url);
      const title = clean(preview.title, 200) || 'LinkedIn post';
      const blog = clean(preview.description, 5000);

      await db.collection('Articles').add({
        titre: title,
        blog,
        image: clean(preview.imageUrl, 2048),
        pdfLink: '',
        category: '',
        source: 'linkedin',
        linkedinUrl: url,
        externalUrl: url,
        author: clean(preview.author, 120),
        addedBy: editor.uid,
        addedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`${tag} ✓ ${title.slice(0, 80)}`);
      ok++;

      // Gentle pacing so LinkedIn doesn't rate-limit us
      await new Promise((r) => setTimeout(r, 1200));
    } catch (e) {
      console.error(`${tag} ✗ ${url.slice(0, 70)}`);
      console.error(`        ${e.message}`);
      err++;
    }
  }

  console.log(`\nDone. ${ok} created, ${dup} duplicates skipped, ${err} errors.\n`);
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
