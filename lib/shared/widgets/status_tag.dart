import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';

enum StatusTagTone { success, warning, info, neutral }

class StatusTag extends StatelessWidget {
  const StatusTag({
    super.key,
    required this.label,
    this.tone = StatusTagTone.neutral,
  });

  final String label;
  final StatusTagTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = switch (tone) {
      StatusTagTone.success => tokens.success,
      StatusTagTone.warning => tokens.warning,
      StatusTagTone.info => tokens.info,
      StatusTagTone.neutral => tokens.primarySubtle,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.black.withAlpha(190),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
