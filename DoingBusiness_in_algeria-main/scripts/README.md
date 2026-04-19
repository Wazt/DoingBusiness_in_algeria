# scripts/

Local admin utilities. None of these ship with the app; they're run manually
from a dev machine with Firebase Admin credentials.

## One-time setup

1. **Get the service account key**
   Firebase Console → ⚙️ Project Settings → **Service accounts** →
   **Generate new private key** → Save file as `scripts/serviceAccountKey.json`.

   ⚠️ **Never commit this file.** It's already listed in `.gitignore` and it
   gives full admin access to the Firebase project.

2. **Install dependencies** (run inside `scripts/`)
   ```bash
   cd scripts
   npm init -y        # only if package.json doesn't exist yet
   npm install firebase-admin
   ```

## Scripts

### `seed-users.mjs` — create test accounts

Creates 3 Firebase Auth users + their Firestore `Users/{uid}` docs.
`editor@grantthornton.dz` gets the `admin: true` custom claim so the
LinkedIn Mirror wizard is visible after they log in.

```bash
node seed-users.mjs
```

**Re-running is safe** — existing users are reused, not duplicated.

Default password for all seeded accounts: `DoBusiness2026!`

To change the user list or passwords, edit the `USERS` array at the top of
the script.

### `grant-admin.mjs` — promote / demote admins

```bash
node grant-admin.mjs alice@grantthornton.dz          # grant
node grant-admin.mjs alice@grantthornton.dz --revoke # revoke
```

The user must **sign out and sign back in** for the new claim to take effect
in their ID token.

## Populating articles — Option A (LinkedIn Mirror)

Once admin is granted and Phase 5 Cloud Functions are deployed:

1. Build & deploy functions
   ```bash
   cd ../functions
   npm install
   npm run build
   firebase deploy --only functions
   ```

2. Deploy Firestore rules
   ```bash
   cd ..
   firebase deploy --only firestore:rules
   ```

3. In the mobile app, log in as the admin account → Profile →
   "Mirror a LinkedIn post" → paste a public LinkedIn URL → preview →
   edit category/title → Publish. Article appears in the feed with the
   LinkedIn source badge.

   **Important:** the Cloud Function fetches only public Open Graph tags
   (title / description / image) of a single URL that the admin explicitly
   pastes. This is different from scraping — no bulk crawling, no automated
   harvesting, one-URL-at-a-time with human consent. This is the approved
   path; see `CLAUDE_CODE_COMPLETE_BRIEF.md` §5 rationale.
