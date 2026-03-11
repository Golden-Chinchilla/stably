import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_text_styles.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class AppTheme {
  static ThemeData light() => _buildTheme(Brightness.light, AppThemeTokens.light);

  static ThemeData dark() => _buildTheme(Brightness.dark, AppThemeTokens.dark);

  static ThemeData _buildTheme(Brightness brightness, AppThemeTokens colors) {
    final baseScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: colors.primary,
      surface: colors.surface,
    );
    final colorScheme = baseScheme.copyWith(
      primary: colors.primary,
      onPrimary: brightness == Brightness.dark ? colors.textPrimary : Colors.white,
      secondary: colors.success,
      onSecondary: colors.background,
      tertiary: colors.info,
      onTertiary: colors.textPrimary,
      error: colors.warning,
      onError: colors.background,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      outline: colors.border,
      shadow: Colors.transparent,
    );
    final textTheme = AppTextStyles.textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      dividerColor: colors.border,
      cardColor: colors.surface,
      shadowColor: Colors.transparent,
      iconTheme: IconThemeData(color: colors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySubtle,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textSecondary,
          ),
        ),
      ),
      extensions: [colors],
    );
  }
}
