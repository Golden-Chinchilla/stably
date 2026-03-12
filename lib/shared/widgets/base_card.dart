import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.block),
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surface,
        border: Border.all(
          color:
              borderColor ??
              tokens.border.withValues(alpha: isDark ? 0.3 : 0.5),
          width: isDark ? 1 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.textPrimary.withValues(alpha: isDark ? 0.05 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: tokens.textPrimary.withValues(alpha: isDark ? 0.02 : 0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
