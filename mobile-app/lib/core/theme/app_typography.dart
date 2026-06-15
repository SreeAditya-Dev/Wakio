import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type system: **Sora** for display/headings (distinctive, geometric),
/// **Inter** for body/labels (highly legible at small sizes).
abstract final class AppTypography {
  static TextTheme textTheme(Color text, Color textSecondary) {
    final heading = GoogleFonts.soraTextTheme();
    final body = GoogleFonts.interTextTheme();

    return TextTheme(
      displayLarge: heading.displayLarge?.copyWith(
        fontWeight: FontWeight.w700, color: text, letterSpacing: -1.5),
      displayMedium: heading.displayMedium?.copyWith(
        fontWeight: FontWeight.w700, color: text, letterSpacing: -1),
      displaySmall: heading.displaySmall?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      headlineLarge: heading.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700, color: text, letterSpacing: -0.5),
      headlineMedium: heading.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      headlineSmall: heading.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      titleLarge: heading.titleLarge?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      titleMedium: body.titleMedium?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      titleSmall: body.titleSmall?.copyWith(
        fontWeight: FontWeight.w500, color: text),
      bodyLarge: body.bodyLarge?.copyWith(color: text),
      bodyMedium: body.bodyMedium?.copyWith(color: text),
      bodySmall: body.bodySmall?.copyWith(color: textSecondary),
      labelLarge: body.labelLarge?.copyWith(
        fontWeight: FontWeight.w600, color: text),
      labelMedium: body.labelMedium?.copyWith(color: textSecondary),
      labelSmall: body.labelSmall?.copyWith(color: textSecondary),
    );
  }

  /// Big mono-feel clock used on Home/Ring screens.
  static TextStyle clock(Color color) => GoogleFonts.sora(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -2,
        height: 1,
      );
}
