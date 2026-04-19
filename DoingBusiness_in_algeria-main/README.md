# DoingBusiness in Algeria

Mobile application for Grant Thornton Algeria's business insights on the
Algerian market.

## Stack

- Flutter 3.24+
- Firebase (Auth, Firestore, FCM, Functions, App Check)
- GetX for state management & navigation
- Material 3 design system (Grant Thornton palette)

## Development

### Setup
```bash
flutter pub get
cd ios && pod install && cd ..
```

### Run
```bash
flutter run
```

### Build release
See [CONTRIBUTING.md](CONTRIBUTING.md).

### Lint & test
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

## Documentation
- [CHANGELOG](CHANGELOG.md)
- [CONTRIBUTING](CONTRIBUTING.md)
