import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class PlaceholderMetricCard extends StatelessWidget {
  const PlaceholderMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    this.tag,
    this.tone = StatusTagTone.neutral,
  });

  final String label;
  final String value;
  final String caption;
  final String? tag;
  final StatusTagTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(label, style: theme.textTheme.labelLarge)),
              if (tag != null) StatusTag(label: tag!, tone: tone),
            ],
          ),
          const SizedBox(height: AppSpacing.item),
          MetricText(
            value,
            size: 26,
            color: tone == StatusTagTone.success ? tokens.success : null,
          ),
          const SizedBox(height: 8),
          Text(caption, style: theme.textTheme.bodySmall),
        ],
      ),
    ).animate().fade(duration: 180.ms).slideY(begin: 0.05, end: 0);
  }
}
