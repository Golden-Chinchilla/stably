import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/app_icon_badge.dart';
import 'package:stably_app/shared/widgets/app_interactive_card.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({
    super.key,
    this.icon = CupertinoIcons.globe,
    required this.platform,
    required this.asset,
    required this.apy,
    required this.summary,
    required this.tags,
    this.tone = StatusTagTone.success,
    this.onTap,
  });

  final IconData icon;
  final String platform;
  final String asset;
  final String apy;
  final String summary;
  final List<String> tags;
  final StatusTagTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AppIconBadge(icon: icon, size: 42, iconSize: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(platform, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(asset, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            MetricText(
              apy,
              size: 20,
              color: tone == StatusTagTone.success ? tokens.success : null,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(summary, style: theme.textTheme.bodySmall),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final tag in tags) StatusTag(label: tag)],
        ),
      ],
    );

    final card = BaseCard(child: content);

    return AppInteractiveCard(onTap: onTap, child: card);
  }
}
