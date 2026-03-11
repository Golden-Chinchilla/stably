import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';

class InfoListCard extends StatelessWidget {
  const InfoListCard({
    super.key,
    required this.title,
    required this.rows,
  });

  final String title;
  final List<({String label, String value, String hint})> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.block),
          for (var index = 0; index < rows.length; index++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rows[index].label, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(rows[index].hint, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                MetricText(rows[index].value),
              ],
            ),
            if (index != rows.length - 1) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}
