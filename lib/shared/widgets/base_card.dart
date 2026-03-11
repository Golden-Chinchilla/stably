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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? tokens.surface,
        border: Border.all(
          color: borderColor ?? tokens.border,
          width: AppSpacing.borderWidth,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
