import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ════════════════════════════════════════════════════════════════════════
///  TYPOGRAPHY — two-typeface system
/// ════════════════════════════════════════════════════════════════════════
///  - Inter (sans, Google Fonts OFL): UI, buttons, captions, short text
///  - Source Serif 4 (serif, OFL)   : article bodies, long-form reading
///
///  Add to pubspec.yaml:
///    fonts:
///      - family: Inter
///        fonts:
///          - asset: assets/fonts/Inter-Regular.ttf
///          - asset: assets/fonts/Inter-Medium.ttf
///            weight: 500
///          - asset: assets/fonts/Inter-SemiBold.ttf
///            weight: 600
///          - asset: assets/fonts/Inter-Bold.ttf
///            weight: 700
///      - family: SourceSerif4
///        fonts:
///          - asset: assets/fonts/SourceSerif4-Regular.ttf
///          - asset: assets/fonts/SourceSerif4-Italic.ttf
///            style: italic
///          - asset: assets/fonts/SourceSerif4-Bold.ttf
///            weight: 700
/// ════════════════════════════════════════════════════════════════════════
class AppTypography {
  AppTypography._();

  static const String ui   = 'Inter';
  static const String body = 'SourceSerif4';

  /// Builds a TextTheme given the text color for this mode (light/dark).
  static TextTheme buildTextTheme(Color textColor, Color secondaryColor) {
    return TextTheme(
      // ─── Display (hero, splash, big titles) ────────────────
      displayLarge: TextStyle(
        fontFamily: ui, fontSize: 57, fontWeight: FontWeight.w700,
        height: 1.12, letterSpacing: -1.2, color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: ui, fontSize: 45, fontWeight: FontWeight.w700,
        height: 1.15, letterSpacing: -0.8, color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: ui, fontSize: 36, fontWeight: FontWeight.w700,
        height: 1.2, letterSpacing: -0.4, color: textColor,
      ),
      // ─── Headlines (screen titles) ─────────────────────────
      headlineLarge: TextStyle(
        fontFamily: ui, fontSize: 32, fontWeight: FontWeight.w700,
        height: 1.25, color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: ui, fontSize: 28, fontWeight: FontWeight.w600,
        height: 1.28, color: textColor,
      ),
      headlineSmall: TextStyle(
        fontFamily: ui, fontSize: 24, fontWeight: FontWeight.w600,
        height: 1.33, color: textColor,
      ),
      // ─── Titles (cards, sections) ──────────────────────────
      titleLarge: TextStyle(
        fontFamily: ui, fontSize: 20, fontWeight: FontWeight.w600,
        height: 1.4, letterSpacing: 0, color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: ui, fontSize: 16, fontWeight: FontWeight.w600,
        height: 1.5, letterSpacing: 0.15, color: textColor,
      ),
      titleSmall: TextStyle(
        fontFamily: ui, fontSize: 14, fontWeight: FontWeight.w600,
        height: 1.43, letterSpacing: 0.1, color: textColor,
      ),
      // ─── Body (UI text — uses Inter) ───────────────────────
      bodyLarge: TextStyle(
        fontFamily: ui, fontSize: 16, fontWeight: FontWeight.w400,
        height: 1.5, letterSpacing: 0.15, color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: ui, fontSize: 14, fontWeight: FontWeight.w400,
        height: 1.5, letterSpacing: 0.25, color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: ui, fontSize: 12, fontWeight: FontWeight.w400,
        height: 1.4, letterSpacing: 0.4, color: secondaryColor,
      ),
      // ─── Labels (buttons, tags, nav) ───────────────────────
      labelLarge: TextStyle(
        fontFamily: ui, fontSize: 14, fontWeight: FontWeight.w600,
        height: 1.43, letterSpacing: 0.5, color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: ui, fontSize: 12, fontWeight: FontWeight.w600,
        height: 1.33, letterSpacing: 0.5, color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: ui, fontSize: 11, fontWeight: FontWeight.w500,
        height: 1.45, letterSpacing: 0.5, color: secondaryColor,
      ),
    );
  }

  // ─── Article-reader-specific (SERIF) ─────────────────────────────
  static TextStyle articleBody(Color color, {double fontSize = 17}) => TextStyle(
    fontFamily: body,
    fontSize: fontSize,
    fontWeight: FontWeight.w400,
    height: 1.7,             // generous line-height for reading
    letterSpacing: 0.1,
    color: color,
  );

  static TextStyle articleLead(Color color) => TextStyle(
    fontFamily: body,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.55,
    color: color,
  );

  static TextStyle articleH2(Color color) => TextStyle(
    fontFamily: ui,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.2,
    color: color,
  );
}
