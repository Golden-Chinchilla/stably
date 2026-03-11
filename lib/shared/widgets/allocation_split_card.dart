import 'package:flutter/material.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';

class AllocationSplitCard extends StatelessWidget {
  const AllocationSplitCard({
    super.key,
    required this.rows,
  });

  final List<({
    String label,
    String value,
    Color color,
    int flex,
  })> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visual split', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  for (final row in rows)
                    Expanded(
                      flex: row.flex,
                      child: ColoredBox(color: row.color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (var index = 0; index < rows.length; index++) ...[
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: rows[index].color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(rows[index].label, style: theme.textTheme.bodyMedium),
                ),
                MetricText(rows[index].value),
              ],
            ),
            if (index != rows.length - 1) ...[
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }
}
