# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased] - Phase 5: LinkedIn Mirror

### Added
- Cloud Functions `previewLinkedInArticle` + `createLinkedInArticle`
  (europe-west1, Gen 2)
- Open Graph scraping via cheerio (title / description / image / author)
- Admin claim enforcement on both callables
- Rate limit: 1 post per admin per minute
- Duplicate detection by URL (prevents double-publish)
- Content caps: title ≤ 200, description ≤ 5000
- Firestore schema extended: `source`, `linkedinUrl`, `externalUrl`, `author`,
  `addedBy`, `addedAt`
- Firestore rules: source validation, admin-only writes, source immutable
  after create (backward compatible: old articles without `source` treated
  as `editorial`)
- Flutter: `ArticleModel` extended with LinkedIn fields + `isLinkedIn` getter
- `AdminRepository` with admin-claim check and typed Cloud Function callers
- `AdminAddLinkedInScreen` — 2-step wizard (paste URL → preview → edit → publish)
- `SourceBadge` + `OpenInLinkedInButton` shared widgets
- Profile screen: conditional "Admin" section (visible only with admin claim)
- Article screen: "Open on LinkedIn" button on LinkedIn-mirror articles
- `scripts/grant-admin.mjs` — Node CLI to set Firebase custom claims
- `cloud_functions` + `url_launcher` dependencies in pubspec.yaml
- 12 URL validator test cases

### Changed
- `ArticleModel` moved from `lib/presentation/Article/models/` to
  `lib/data/models/` (better layering). All 12 existing imports updated.

### ⚠️ MANUAL SETUP REQUIRED

1. **Upgrade Firebase project to Blaze plan** (required for Cloud Functions Gen 2)
2. **Grant admin claim to editorial users**:
   ```bash
   cd scripts
   npm install firebase-admin
   # Download service account JSON from Firebase Console → Settings → Service accounts
   # Save as scripts/serviceAccountKey.json  (gitignored)
   node grant-admin.mjs editor@grantthornton.dz
   ```
3. **Build & deploy functions**:
   ```bash
   cd functions && npm install && npm run build && cd ..
   firebase deploy --only functions
   ```
4. **Deploy extended Firestore rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```
5. **(Optional, recommended)** Enable Firebase App Check (Play Integrity + App
   Attest), then flip `enforceAppCheck: true` in `functions/src/linkedin.ts`
   and redeploy.

### Cost

- Cloud Functions: ~0$/month at expected volume (well within 2M free invocations)
- Firestore writes: negligible (~15/month for posts)

### Rationale

Chosen over LinkedIn scraping (CGU violation, legal risk for GT) and over
official LinkedIn API (2-6 week approval, OAuth complexity). This "link embed"
approach is fully legal (only public OG tags), ships in 1 week, and can
migrate to official API later without breaking the data model.
