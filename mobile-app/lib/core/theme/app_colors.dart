import 'package:flutter/material.dart';

/// Brand palette — Orange (#F97316) + Black, per the product spec.
/// Light + dark tokens live here so the rest of the app never hardcodes a hex.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFFF97316);
  static const Color primaryHover = Color(0xFFFB923C);

  // Dark theme
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkCard = Color(0xFF262626);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA3A3A3);

  // Light theme
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF171717);
  static const Color lightTextSecondary = Color(0xFF525252);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Fixed
  static const Color onPrimary = Color(0xFF0A0A0A);
}

/// Extra brand-specific colors that don't fit Material's [ColorScheme].
/// Accessed via `Theme.of(context).extension<AppColorsExt>()!`.
@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.textSecondary,
    required this.card,
    required this.success,
    required this.warning,
    required this.primaryHover,
  });

  final Color textSecondary;
  final Color card;
  final Color success;
  final Color warning;
  final Color primaryHover;

  static const dark = AppColorsExt(
    textSecondary: AppColors.darkTextSecondary,
    card: AppColors.darkCard,
    success: AppColors.success,
    warning: AppColors.warning,
    primaryHover: AppColors.primaryHover,
  );

  static const light = AppColorsExt(
    textSecondary: AppColors.lightTextSecondary,
    card: AppColors.lightCard,
    success: AppColors.success,
    warning: AppColors.warning,
    primaryHover: AppColors.primaryHover,
  );

  @override
  AppColorsExt copyWith({
    Color? textSecondary,
    Color? card,
    Color? success,
    Color? warning,
    Color? primaryHover,
  }) =>
      AppColorsExt(
        textSecondary: textSecondary ?? this.textSecondary,
        card: card ?? this.card,
        success: success ?? this.success,
        warning: warning ?? this.warning,
        primaryHover: primaryHover ?? this.primaryHover,
      );

  @override
  AppColorsExt lerp(AppColorsExt? other, double t) {
    if (other == null) return this;
    return AppColorsExt(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      card: Color.lerp(card, other.card, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
    );
  }
}
