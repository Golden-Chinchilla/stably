import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AlertRuleCard extends StatelessWidget {
  const AlertRuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.frequency,
    required this.tone,
    this.statusLabel,
    this.secondaryTags = const [],
    this.footer,
  });

  final String title;
  final String description;
  final String frequency;
  final StatusTagTone tone;
  final String? statusLabel;
  final List<String> secondaryTags;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              StatusTag(label: frequency, tone: tone),
            ],
          ),
          if (statusLabel != null || secondaryTags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.item),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (statusLabel != null)
                  StatusTag(label: statusLabel!, tone: tone),
                for (final tag in secondaryTags) StatusTag(label: tag),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.item),
          Text(description, style: theme.textTheme.bodySmall),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.item),
            footer!,
          ],
        ],
      ),
    );
  }
}
