#!/usr/bin/env node
/**
 * seed-users.mjs — create test Auth users + Firestore User docs for staging.
 *
 * Prereqs
 *   1. Download the service account JSON from Firebase Console
 *      → Project Settings → Service accounts → Generate new private key
 *   2. Save as `scripts/serviceAccountKey.json` (gitignored)
 *   3. From `scripts/` run:  npm install firebase-admin
 *
 * Usage
 *   cd scripts && node seed-users.mjs
 *
 * What it does
 *   - Creates 3 Firebase Auth users (idempotent — skips if email already exists)
 *   - Writes matching /Users/{uid} Firestore docs
 *   - Grants `admin: true` custom claim to the editor account so the
 *     LinkedIn Mirror feature is unlocked for that login
 *
 * Change the USERS array below to customise.
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';

const serviceAccount = JSON.parse(
  readFileSync('./serviceAccountKey.json', 'utf8')
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const DEFAULT_PASSWORD = 'DoBusiness2026!';

const USERS = [
  {
    email: 'editor@grantthornton.dz',
    username: 'GT Editor',
    password: DEFAULT_PASSWORD,
    admin: true,
  },
  {
    email: 'reader1@test.doingbusiness.dz',
    username: 'Sarah Benali',
    password: DEFAULT_PASSWORD,
    admin: false,
  },
  {
    email: 'reader2@test.doingbusiness.dz',
    username: 'Karim Boudiaf',
    password: DEFAULT_PASSWORD,
    admin: false,
  },
];

async function ensureUser(cfg) {
  const { email, username, password, admin: isAdmin } = cfg;

  let userRecord;
  try {
    userRecord = await admin.auth().getUserByEmail(email);
    console.log(`• ${email} already exists (uid ${userRecord.uid}) — reusing`);
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: username,
      emailVerified: true,
    });
    console.log(`✓ Created Auth user ${email} (uid ${userRecord.uid})`);
  }

  // Firestore doc matches the Flutter UserModel shape: { username, email }
  const userDoc = admin.firestore().collection('Users').doc(userRecord.uid);
  await userDoc.set(
    { username, email, fcmTokens: [] },
    { merge: true }
  );
  console.log(`  → wrote Users/${userRecord.uid}`);

  if (isAdmin) {
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });
    console.log(`  → granted admin claim`);
  } else {
    // Explicitly clear to be safe on re-runs.
    const existing = (await admin.auth().getUser(userRecord.uid)).customClaims || {};
    if (existing.admin) {
      const { admin: _drop, ...rest } = existing;
      await admin.auth().setCustomUserClaims(userRecord.uid, rest);
      console.log(`  → removed admin claim (was set)`);
    }
  }

  return userRecord;
}

(async () => {
  console.log(`\nSeeding ${USERS.length} users into Firebase project "${serviceAccount.project_id}"…\n`);
  for (const cfg of USERS) {
    try {
      await ensureUser(cfg);
    } catch (err) {
      console.error(`✗ ${cfg.email} failed:`, err.message);
      process.exitCode = 1;
    }
  }

  console.log('\nDone.\n');
  console.log('Login credentials (all passwords are the same):');
  console.log(`  password: ${DEFAULT_PASSWORD}\n`);
  USERS.forEach((u) =>
    console.log(`  ${u.admin ? '[ADMIN]' : '       '} ${u.email}  — ${u.username}`)
  );
  console.log(`
⚠️  Admin claim takes effect only after the user signs in again —
   the ID token is cached for ~1h otherwise.
`);
  process.exit();
})();
