import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class RiskNoticeCard extends StatelessWidget {
  const RiskNoticeCard({
    super.key,
    required this.title,
    required this.description,
    required this.tone,
  });

  final String title;
  final String description;
  final StatusTagTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    final accent = switch (tone) {
      StatusTagTone.success => tokens.success,
      StatusTagTone.warning => tokens.warning,
      StatusTagTone.info => tokens.info,
      StatusTagTone.neutral => tokens.primarySubtle,
    };

    return BaseCard(
      backgroundColor: accent.withAlpha(22),
      borderColor: accent.withAlpha(90),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.item),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(description, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
