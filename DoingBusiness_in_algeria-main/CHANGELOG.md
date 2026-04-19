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
