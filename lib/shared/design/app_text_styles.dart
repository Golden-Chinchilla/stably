import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class AppTextStyles {
  static TextTheme textTheme(AppThemeTokens colors) {
    final titleColor =
        colors.background.computeLuminance() < 0.2 ? colors.primarySubtle : colors.primary;

    return TextTheme(
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.1,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: colors.textPrimary,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: titleColor,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: titleColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: colors.textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: colors.textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: titleColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colors.textSecondary,
      ),
    );
  }

  static TextStyle metricStyle(
    BuildContext context, {
    double size = 16,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.robotoMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? context.tokens.textPrimary,
      height: 1.2,
    );
  }
}
