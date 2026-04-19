import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// ════════════════════════════════════════════════════════════════════════
///  APP THEME — Material 3, accessible, brand-consistent
/// ════════════════════════════════════════════════════════════════════════
///  Swap the old AppTheme in main.dart for:
///     theme:     AppTheme.light(),
///     darkTheme: AppTheme.dark(),
///     themeMode: controller.themeMode,   // from ProfileController
/// ════════════════════════════════════════════════════════════════════════
class AppTheme {
  AppTheme._();

  // ─── Light theme ──────────────────────────────────────────────────────
  static ThemeData light() {
    final cs = ColorScheme(
      brightness: Brightness.light,
      primary:         AppColors.brandPurple,
      onPrimary:       Colors.white,
      primaryContainer: AppColors.brandPurpleLight.withOpacity(0.15),
      onPrimaryContainer: AppColors.brandPurpleDark,
      secondary:       AppColors.brandCoral,
      onSecondary:     Colors.white,
      secondaryContainer: AppColors.brandCoralLight.withOpacity(0.12),
      onSecondaryContainer: AppColors.brandCoral,
      error:           AppColors.error,
      onError:         Colors.white,
      surface:         AppColors.lightSurface,
      onSurface:       AppColors.lightText,
      surfaceContainerHighest: AppColors.lightSurfaceAlt,
      outline:         AppColors.lightBorder,
      outlineVariant:  AppColors.lightBorder.withOpacity(0.5),
    );

    return _buildTheme(
      colorScheme: cs,
      textTheme:   AppTypography.buildTextTheme(AppColors.lightText, AppColors.lightTextSecondary),
      surfaceAlt:  AppColors.lightSurfaceAlt,
      border:      AppColors.lightBorder,
      textSecondary: AppColors.lightTextSecondary,
    );
  }

  // ─── Dark theme ───────────────────────────────────────────────────────
  static ThemeData dark() {
    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary:         AppColors.brandPurpleLight,
      onPrimary:       AppColors.brandPurpleDark,
      primaryContainer: AppColors.brandPurple.withOpacity(0.3),
      onPrimaryContainer: AppColors.brandPurpleLight,
      secondary:       AppColors.brandCoralLight,
      onSecondary:     Color(0xFF2A0508),
      secondaryContainer: AppColors.brandCoral.withOpacity(0.2),
      onSecondaryContainer: AppColors.brandCoralLight,
      error:           Color(0xFFFF6B6B),
      onError:         Color(0xFF2A0508),
      surface:         AppColors.darkSurface,
      onSurface:       AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceAlt,
      outline:         AppColors.darkBorder,
      outlineVariant:  AppColors.darkBorder.withOpacity(0.5),
    );

    return _buildTheme(
      colorScheme: cs,
      textTheme:   AppTypography.buildTextTheme(AppColors.darkText, AppColors.darkTextSecondary),
      surfaceAlt:  AppColors.darkSurfaceAlt,
      border:      AppColors.darkBorder,
      textSecondary: AppColors.darkTextSecondary,
    );
  }

  // ─── Shared theme builder ─────────────────────────────────────────────
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required TextTheme   textTheme,
    required Color       surfaceAlt,
    required Color       border,
    required Color       textSecondary,
  }) {
    final isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      textTheme: textTheme,
      fontFamily: AppTypography.ui,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      splashFactory: InkSparkle.splashFactory,

      // ─── AppBar ─────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),

      // ─── Buttons ─────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ─── Inputs ─────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical:   AppSpacing.lg,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // ─── Cards ──────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border, width: 0.8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        margin: EdgeInsets.zero,
      ),

      // ─── Bottom navigation ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        height: 72,
        indicatorColor: colorScheme.primary.withOpacity(0.1),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelSmall),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 26);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // ─── Dividers ───────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.8,
        space: 0,
      ),

      // ─── Snackbars ──────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),

      // ─── Chips (tags) ───────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: colorScheme.primary.withOpacity(0.15),
        side: BorderSide(color: border),
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
    );
  }
}
