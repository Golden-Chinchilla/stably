import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';

class SectionBlock extends StatelessWidget {
  const SectionBlock({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[trailing!],
          ],
        ),
        const SizedBox(height: AppSpacing.block),
        child,
      ],
    );
  }
}
