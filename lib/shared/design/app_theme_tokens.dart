import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.primary,
    required this.primarySubtle,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color primary;
  final Color primarySubtle;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color warning;
  final Color info;

  static const light = AppThemeTokens(
    primary: Color(0xFF4A5D23),
    primarySubtle: Color(0xFFE4E8DE),
    background: Color(0xFFFBFBF9),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1B2215),
    textSecondary: Color(0xFF818A7A),
    border: Color(0xFFEBEBE6),
    success: Color(0xFFB2E159),
    warning: Color(0xFFD9A05B),
    info: Color(0xFF5E93A5),
  );

  static const dark = AppThemeTokens(
    primary: Color(0xFF4A5D23),
    primarySubtle: Color(0xFFE4E8DE),
    background: Color(0xFF181A17),
    surface: Color(0xFF222620),
    textPrimary: Color(0xFFF4F5F2),
    textSecondary: Color(0xFF9AA392),
    border: Color(0xFF31382D),
    success: Color(0xFFB2E159),
    warning: Color(0xFFD9A05B),
    info: Color(0xFF5E93A5),
  );

  @override
  ThemeExtension<AppThemeTokens> copyWith({
    Color? primary,
    Color? primarySubtle,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppThemeTokens(
      primary: primary ?? this.primary,
      primarySubtle: primarySubtle ?? this.primarySubtle,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppThemeTokens> lerp(
    covariant ThemeExtension<AppThemeTokens>? other,
    double t,
  ) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primarySubtle:
          Color.lerp(primarySubtle, other.primarySubtle, t) ?? primarySubtle,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }
}

extension AppThemeTokensBuildContext on BuildContext {
  AppThemeTokens get tokens => Theme.of(this).extension<AppThemeTokens>()!;
}
