# Changelog

All notable changes to this project will be documented in this file.

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
