import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════════════
///  SPACING — 4pt grid
/// ════════════════════════════════════════════════════════════════════════
///  All paddings, margins, and gaps should be multiples of 4.
///  This produces consistent rhythm across screens.
/// ════════════════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();

  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 20;
  static const double xxl = 24;
  static const double huge = 32;
  static const double massive = 48;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenPaddingWide = EdgeInsets.symmetric(horizontal: xxl);

  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // Radius
  static const double radiusSm  = 8;
  static const double radiusMd  = 12;
  static const double radiusLg  = 16;
  static const double radiusXl  = 24;

  // Gaps
  static const SizedBox gapXs  = SizedBox(height: xs,  width: xs);
  static const SizedBox gapSm  = SizedBox(height: sm,  width: sm);
  static const SizedBox gapMd  = SizedBox(height: md,  width: md);
  static const SizedBox gapLg  = SizedBox(height: lg,  width: lg);
  static const SizedBox gapXl  = SizedBox(height: xl,  width: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl, width: xxl);
}
