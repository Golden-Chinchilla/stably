import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/widgets/app_icon_badge.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';

class InsightTile extends StatelessWidget {
  const InsightTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBadge(icon: icon),
          const SizedBox(height: AppSpacing.item),
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          MetricText(value, size: 20),
          const SizedBox(height: 6),
          Text(caption, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
