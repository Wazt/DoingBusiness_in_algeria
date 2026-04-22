#!/usr/bin/env node
/**
 * cleanup-placeholder-images.mjs
 * Removes the LinkedIn "sign in" placeholder that was inadvertently stored
 * for 14 of 17 articles (identical md5 across all of them). Clears their
 * `image` field so the app falls back to the _HeroGradient.
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';

const sa = JSON.parse(readFileSync('./serviceAccountKey.json', 'utf8'));
admin.initializeApp({
  credential: admin.credential.cert(sa),
  storageBucket: 'doingbusinessbygrantthorntondz.firebasestorage.app',
});

const db = admin.firestore();
const bucket = admin.storage().bucket();

// md5 of the known LinkedIn "sign in" placeholder we got back 14 times
const PLACEHOLDER_MD5 = 'zKRkWrWrnmRqbruOpgDbAw==';

async function main() {
  const [files] = await bucket.getFiles({ prefix: 'articles/' });
  let deletedFiles = 0, clearedDocs = 0;

  for (const f of files) {
    const [md] = await f.getMetadata();
    if (md.md5Hash !== PLACEHOLDER_MD5) continue;

    const articleId = md.name.replace(/^articles\//, '').replace(/\.jpg$/, '');

    // Delete the storage file
    await f.delete({ ignoreNotFound: true });
    deletedFiles++;

    // Clear the image field on the article doc
    await db.collection('Articles').doc(articleId).update({ image: '' });
    clearedDocs++;

    console.log(`✓ cleaned ${articleId}`);
  }

  console.log(`\nDone. Deleted ${deletedFiles} placeholder files, cleared ${clearedDocs} article image fields.`);
  process.exit(0);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
