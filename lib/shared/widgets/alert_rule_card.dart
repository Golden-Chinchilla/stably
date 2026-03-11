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
  });

  final String title;
  final String description;
  final String frequency;
  final StatusTagTone tone;

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
          const SizedBox(height: AppSpacing.item),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
