import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Material 3 light/dark themes built from the brand tokens.
abstract final class AppTheme {
  static const _radius = 16.0;

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        textSecondary: AppColors.darkTextSecondary,
        colorsExt: AppColorsExt.dark,
        overlay: SystemUiOverlayStyle.light,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        text: AppColors.lightText,
        textSecondary: AppColors.lightTextSecondary,
        colorsExt: AppColorsExt.light,
        overlay: SystemUiOverlayStyle.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color textSecondary,
    required AppColorsExt colorsExt,
    required SystemUiOverlayStyle overlay,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primaryHover,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: colorsExt.card,
      onSurfaceVariant: textSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme(text, textSecondary),
      extensions: [colorsExt],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: overlay.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: AppTypography.textTheme(text, textSecondary).titleLarge,
        iconTheme: IconThemeData(color: text),
      ),
      cardTheme: CardThemeData(
        color: colorsExt.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 16, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorsExt.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary.withValues(alpha: 0.4)
              : null,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: DividerThemeData(
        color: textSecondary.withValues(alpha: 0.15),
        thickness: 1,
      ),
    );
  }
}
