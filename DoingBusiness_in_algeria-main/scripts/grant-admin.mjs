#!/usr/bin/env node
/**
 * ════════════════════════════════════════════════════════════════════════
 *  grant-admin.mjs — set `admin: true` custom claim on a user
 * ════════════════════════════════════════════════════════════════════════
 *
 *  Prerequisites:
 *    1. Download service account JSON:
 *       Firebase Console → Project Settings → Service accounts → Generate new private key
 *    2. Save as `serviceAccountKey.json` in the same folder as this script
 *    3. npm install firebase-admin
 *
 *  Usage:
 *    node grant-admin.mjs <user-email>
 *
 *  Example:
 *    node grant-admin.mjs editor@grantthornton.dz
 *
 *  To REVOKE admin:
 *    node grant-admin.mjs <user-email> --revoke
 *
 *  ⚠️ The user must sign out and sign back in (or call getIdToken(true))
 *     before the new claim takes effect on the client.
 * ════════════════════════════════════════════════════════════════════════
 */

import admin from 'firebase-admin';
import { readFileSync } from 'node:fs';

const serviceAccount = JSON.parse(
  readFileSync('./serviceAccountKey.json', 'utf8')
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const [email, flag] = process.argv.slice(2);
const revoke = flag === '--revoke';

if (!email) {
  console.error('Usage: node grant-admin.mjs <email> [--revoke]');
  process.exit(1);
}

try {
  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, { admin: !revoke });

  console.log(
    revoke
      ? `✓ Revoked admin from ${email} (uid: ${user.uid})`
      : `✓ Granted admin to ${email} (uid: ${user.uid})`
  );
  console.log(
    '\n⚠️  The user must sign out and sign back in for the new claim to take effect.'
  );
  process.exit(0);
} catch (err) {
  console.error('✗ Failed:', err.message);
  process.exit(1);
}
