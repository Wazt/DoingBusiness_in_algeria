# Distribution — Android testing with clients

End-to-end guide to run the app locally on your Windows machine, then ship
builds to clients via **Firebase App Distribution** (free, no Play Store needed).

---

## 1. Run it locally (Windows)

### 1.1 Install toolchain (one-time, ~20-30 min)

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install/windows
   - Download the zip, extract to `C:\src\flutter`
   - Add `C:\src\flutter\bin` to your PATH
2. **Android Studio** — https://developer.android.com/studio
   - Needed for the Android SDK, emulator, and build tools
   - During setup: let it download Android SDK (API 34) + Android Emulator
3. **Java 17 (JDK)** — Phase 2 requires it
   - `winget install Microsoft.OpenJDK.17`
   - Or Zulu: https://www.azul.com/downloads/?version=java-17-lts
4. **Git for Windows** — already installed (we used it).

### 1.2 Verify

Open a fresh PowerShell or Git Bash:

```bash
flutter doctor -v
```

You want green checks on: Flutter, Android toolchain, Android Studio, Chrome (optional).
Anything red, `flutter doctor` tells you exactly what's missing.

### 1.3 Accept Android SDK licenses (first time only)

```bash
flutter doctor --android-licenses
```

Press `y` to accept everything.

### 1.4 Clone & run

```bash
cd C:\Users\User\Dev
# Repo is already cloned. Pull the latest merged main.
cd DoingBusiness_in_algeria
git pull origin main
cd DoingBusiness_in_algeria-main

flutter pub get
flutter run
```

If you don't have a physical Android device with USB debugging, open Android
Studio → Device Manager → Create Virtual Device → Pixel 7 / Android 14 →
Start, then re-run `flutter run`.

First build takes ~10 minutes (Gradle downloads dependencies).

---

## 2. Build a debug APK you can email / Drive-share

```bash
cd DoingBusiness_in_algeria-main
flutter build apk --debug
```

The APK is at `build/app/outputs/flutter-apk/app-debug.apk`. You can send
this file directly to testers — they enable "Install from unknown sources"
on their Android device and install it. Good for a small trusted group.

For anything beyond 2-3 testers, use Firebase App Distribution (next section).

---

## 3. Firebase App Distribution — invite clients by email

### 3.1 Get the Android App ID

Firebase Console → Project Settings → *Your apps* → Android app → look for
`App ID`, format `1:617006158041:android:abc123…`. Copy it.

If you don't see an Android app there, click **Add app → Android** first:
- Package name: `com.grantthorntondz.doingbusiness`
- Download the new `google-services.json` and replace the one in
  `DoingBusiness_in_algeria-main/android/app/`

### 3.2 Create a tester group

Firebase Console → **App Distribution** → **Testers & Groups** tab →
**Add group** → name it `testers` (the CI workflow expects this name).

Then click the group → **Add testers** → paste client email addresses
(one per line). Each tester will get a welcome email with a link to
`appdistribution.firebase.dev` where they can install the app.

### 3.3 Create a service account for the CI

GCP Console → IAM & Admin → Service Accounts → **Create service account**:
- Name: `github-actions-distribution`
- Role: **Firebase App Distribution Admin**
- Click Done

Then click the account → **Keys** → **Add key** → **Create new key** →
JSON → download. Keep this file safe — it's a credential.

### 3.4 Add two GitHub repo secrets

GitHub → Settings → Secrets and variables → Actions → **New repository secret**:

| Name | Value |
|------|-------|
| `FIREBASE_ANDROID_APP_ID` | the `1:617006…:android:…` string |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | the entire contents of the JSON file from 3.3 (open it and paste the raw JSON) |

### 3.5 Trigger a distribution

Any push to `main` now runs the `ci.yml` workflow → builds a debug APK →
uploads it to App Distribution → emails the `testers` group. You can also
trigger it manually: GitHub → Actions → **ci** → **Run workflow** → branch `main`.

First distribution usually takes ~10 minutes. Each tester's email link expires
after 15 days but they can always go to the App Distribution page to grab the
latest build.

---

## 4. Monitoring / cost

- App Distribution itself is **free** regardless of volume.
- GitHub Actions: public repos = free, private repos = 2000 min/month free
  (this workflow is ~8 min per push, so ~250 pushes/month free).
- Firebase Blaze plan + `$1` budget alert (set in GCP Billing → Budgets)
  protects against any surprise charges from the LinkedIn Cloud Functions.

---

## 5. Troubleshooting

### `flutter analyze` fails on CI
The Phase 4 build.gradle needs a `key.properties` for release builds. Debug
builds work fine without it. The CI workflow uses `flutter build apk --debug`
for this reason — don't switch to `--release` until you have a keystore.

### Testers say "App not installed"
- Android may refuse to replace a release-signed app with a debug-signed one.
  Ask testers to uninstall any existing copy first.
- Make sure testers enabled *Install from unknown sources* in their browser.

### CI `dart format` fails
We marked the format step `|| true` in `ci.yml` because Windows CRLF line
endings generate noise. Once the team settles on LF-only, remove the `|| true`.

### LinkedIn feature doesn't work in testers' build
The Cloud Functions must be deployed (`firebase deploy --only functions`) AND
at least one user must have the admin custom claim (`scripts/grant-admin.mjs`).
Without both, the admin wizard in Profile won't appear.
