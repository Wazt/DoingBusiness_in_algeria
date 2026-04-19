import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════════════
///  APP COLORS — DoingBusiness in Algeria
/// ════════════════════════════════════════════════════════════════════════
///  Derived from Grant Thornton brand guidelines:
///    - Primary: purple (#4E2780) — trust, professionalism, brand recognition
///    - Accent : coral (#E83A4E) — CTAs, attention without being aggressive
///    - Neutrals tuned for long-form reading (warm whites, not pure #FFF)
/// ════════════════════════════════════════════════════════════════════════
class AppColors {
  AppColors._();

  // ─── Brand (Grant Thornton) ──────────────────────────────────────────
  static const Color brandPurple       = Color(0xFF4E2780);
  static const Color brandPurpleLight  = Color(0xFF8847BB);
  static const Color brandPurpleDark   = Color(0xFF2E1650);
  static const Color brandCoral        = Color(0xFFE83A4E);
  static const Color brandCoralLight   = Color(0xFFFF6B7A);

  // ─── Semantic (feedback) ─────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFE67E22);
  static const Color error   = Color(0xFFCE2C2C);
  static const Color info    = Color(0xFF1976D2);

  // ─── Light theme neutrals ────────────────────────────────────────────
  static const Color lightBg            = Color(0xFFFAF9FB);  // warm off-white
  static const Color lightSurface       = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt    = Color(0xFFF1EEF4);  // cards, inputs
  static const Color lightBorder        = Color(0xFFE5E2EA);
  static const Color lightText          = Color(0xFF1A1423);
  static const Color lightTextSecondary = Color(0xFF5E5770);
  static const Color lightTextTertiary  = Color(0xFF8F8899);

  // ─── Dark theme neutrals ─────────────────────────────────────────────
  static const Color darkBg            = Color(0xFF13101A);   // deep purple-black
  static const Color darkSurface       = Color(0xFF1C1827);
  static const Color darkSurfaceAlt    = Color(0xFF2A2438);
  static const Color darkBorder        = Color(0xFF3A3348);
  static const Color darkText          = Color(0xFFF0EDF4);
  static const Color darkTextSecondary = Color(0xFFB8B0C4);
  static const Color darkTextTertiary  = Color(0xFF7F7890);

  // ─── Category tags (editorial / subtle) ──────────────────────────────
  static const Color tagFinance   = Color(0xFF2E7D8B);
  static const Color tagLegal     = Color(0xFF5D4E8B);
  static const Color tagTax       = Color(0xFF8B5E3C);
  static const Color tagHR        = Color(0xFF6B8E3C);

  /// Deprecated aliases — keep for compat while migrating.
  /// TODO(cleanup): delete after all screens use the new names.
  static const primaryLight    = brandPurpleLight;
  static const primaryDark     = brandPurple;
  static const dangerRed       = error;
  static const mediumGreen     = success;
  static const warrningOrange  = warning;   // typo kept for compat, new code must use `warning`
}
