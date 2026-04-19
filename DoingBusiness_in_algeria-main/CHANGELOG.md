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
  `lib/data/models/` (better layering). All existing imports updated.

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

## [Unreleased] - Phase 4: Design system, CI & tests

### Added
- Design system: `app_colors.dart`, `app_typography.dart`, `app_spacing.dart`,
  `app_theme.dart` (Grant Thornton palette: deep purple `#4E2780` + coral `#E83A4E`)
- Complete Material 3 light + dark themes (`AppTheme.light()` / `AppTheme.dark()`)
- `analysis_options.yaml` with strict linter (`avoid_print: error`, etc.)
- `.github/workflows/ci.yml` — GitHub Actions CI (analyze + test + build on PR)
- 12 validator unit tests (`test/validators_test.dart`) — replaces default
  counter template test
- README rewritten (was default Flutter template)

### Changed
- `login_screen`: removed `BackdropFilter`, added `autofillHints`, M3-native
- `main_wrapper`: Material 3 `NavigationBar`, Saved tab re-enabled, Discover typo fixed
- `home_screen`: feed-style with featured hero + category chips + latest list,
  shimmer placeholders + pull-to-refresh
- 23 `print()` calls swept to `debugPrint()` (stripped in release)
- `main.dart` + `profile_controller.dart` migrated to new `AppTheme.light()` /
  `AppTheme.dark()` API

### ⚠️ MANUAL STEP

Place the OFL-licensed font files in `assets/fonts/` and uncomment the `fonts:`
block in `pubspec.yaml`:
- Inter: `Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf`
- Source Serif 4: `SourceSerif4-Regular.ttf`, `SourceSerif4-Italic.ttf`, `SourceSerif4-Bold.ttf`

Download from https://fonts.google.com/.

## [Unreleased] - Phase 3: Security & GDPR

### Added
- Versioned Firestore security rules (`firestore.rules`)
- `firebase.json` for project configuration

### Security
- Default-deny on all Firestore paths
- Public read on `Articles` + `categories`
- Admin-only writes (custom claim `admin: true`)
- Owner-only read/write on `Users/{uid}`
- Username length validation (2-60 chars)
- Email field immutable on update

### GDPR
- Complete account deletion (Auth + Firestore doc) — see Phase 1
- Documentation of manual steps (API key restriction, admin claims,
  data-deletion URL publishing)

### ⚠️ MANUAL STEPS REQUIRED

1. Restrict Firebase API keys in Google Cloud Console
2. Grant admin claim to editorial accounts (see Phase 5 scripts)
3. Publish Privacy Policy URL + Data Deletion URL
4. Deploy the rules: `firebase deploy --only firestore:rules`

## [Unreleased] - Phase 2: Toolchain modernization

### Changed

Android:
- AGP 4.2.2 → 8.3.2 (required for targetSdk 34)
- Gradle 7.5 → 8.4
- Kotlin 1.7.10 → 1.9.22
- Java 8 → Java 17
- compileSdk / targetSdk → 34 (Google Play requirement since Aug 31 2024)
- ProGuard/R8 enabled with full rules for Firebase/Flutter/Syncfusion
- Release signing hard-fails if `key.properties` is missing
- `network_security_config.xml`: HTTPS-only enforced
- `data_extraction_rules.xml`: cloud backup of sensitive data disabled
- `AndroidManifest`: POST_NOTIFICATIONS added (Android 13+), legacy storage removed

iOS:
- `PrivacyInfo.xcprivacy` added (Apple mandatory since spring 2024)
- `Info.plist`: proper display name, usage descriptions

Ops:
- `CONTRIBUTING.md` added (build + release instructions)
- `.gitignore`: keystore, service account keys, functions build output

### ⚠️ MANUAL STEP REQUIRED BEFORE iOS BUILD

Open `ios/Runner.xcworkspace` in Xcode → right-click `Runner` folder → Add Files
to "Runner" → select `PrivacyInfo.xcprivacy` → ensure "Copy items if needed" is
checked and target `Runner` is ticked.

## [Unreleased] - Phase 1: Quick fixes

- 19 functional bug fixes (validators, splash crash, reauth, GDPR opt-out, etc.)
- 9 typos swept (`warrning`, `pirvacy`, `Unkown`, `Dsicover`, etc.)
- iOS bundle ID `com.example.*` → `com.grantthorntondz.doingbusiness`
- Android MainActivity moved to `com.grantthorntondz.doingbusiness` package
