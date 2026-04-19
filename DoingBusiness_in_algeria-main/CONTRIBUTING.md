# Contributing to DoingBusiness in Algeria

## Building a release APK/AAB

1. Generate a release keystore (one-time, save somewhere safe):
   ```bash
   keytool -genkey -v -keystore ~/doingbusiness-release.jks \
           -keyalg RSA -keysize 2048 -validity 10000 -alias doingbusiness
   ```

2. Copy `android/key.properties.sample` to `android/key.properties` (gitignored)
   and fill in real values.

3. Build:
   ```bash
   flutter build appbundle --release
   ```

## Building iOS

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **First time only**: right-click on `Runner` folder → Add Files to "Runner"
   → select `PrivacyInfo.xcprivacy` → ensure "Copy items if needed" is checked
   and target Runner is ticked. This adds it to the "Copy Bundle Resources"
   build phase. Without this step, Apple rejects the build at review time.
3. Product → Archive → Upload to App Store Connect.

## Toolchain prerequisites

- **Java 17** (required by AGP 8)
  - macOS: `brew install openjdk@17`
  - Linux: `sdk install java 17.0.11-zulu`
- **Flutter 3.24+ stable**
- **Node 20+** (Phase 5 Cloud Functions + admin scripts)

## Validation before PR

```bash
flutter clean && flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter build apk --debug
```
