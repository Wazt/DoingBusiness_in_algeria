# Changelog

All notable changes to this project will be documented in this file.

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
