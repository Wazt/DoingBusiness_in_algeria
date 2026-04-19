# Changelog

All notable changes to this project will be documented in this file.

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

#### 1. Restrict Firebase API keys in Google Cloud Console

Go to https://console.cloud.google.com/apis/credentials?project=doingbusinessbygrantthornton
and restrict each key:

- **Android key**: Application restrictions → Android apps → add
  `com.grantthorntondz.doingbusiness` + release SHA-1 (from Play Console → App
  Signing → Upload certificate)
- **iOS key**: Application restrictions → iOS apps → add bundle ID
  `com.grantthorntondz.doingbusiness`
- **Web key**: HTTP referrers only → add your Privacy Policy URL domain

#### 2. Grant admin custom claim to editorial accounts

Before deploying Firestore rules, at least one account must have `admin: true`
claim. Otherwise nobody will be able to publish articles.

```bash
cd scripts    # after Phase 5 is merged
node grant-admin.mjs editor@grantthornton.dz
```

The user must sign out and sign back in for the claim to take effect.

#### 3. Publish Privacy Policy URL + Data Deletion URL

Required by Google Play Console Data Safety form AND by the new Firestore rules
(which enforce GDPR Article 17 "right to erasure"). A simple GitHub Pages
static site is sufficient.

#### 4. Deploy the rules

```bash
firebase login
firebase use doingbusinessbygrantthornton
firebase deploy --only firestore:rules
```

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

Without this step, the file is on disk but NOT in the app bundle, and Apple
will reject the build at review time.

## [Unreleased] - Phase 1: Quick fixes

See commit `fix/phase1-quick-fixes` for full details. Summary:

- 19 functional bug fixes (validators, splash crash, reauth, GDPR opt-out, etc.)
- 9 typos swept (`warrning`, `pirvacy`, `Unkown`, `Dsicover`, etc.)
- iOS bundle ID `com.example.*` → `com.grantthorntondz.doingbusiness`
- Android MainActivity moved to `com.grantthorntondz.doingbusiness` package
