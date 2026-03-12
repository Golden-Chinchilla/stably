import 'package:flutter/material.dart';
import 'package:stably_app/shared/design/app_spacing.dart';
import 'package:stably_app/shared/design/app_theme_tokens.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/metric_text.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class HighlightPanel extends StatelessWidget {
  const HighlightPanel({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.value,
    required this.secondaryValue,
    required this.tag,
    this.tone = StatusTagTone.success,
    this.footer,
  });

  final String eyebrow;
  final String title;
  final String description;
  final String value;
  final String secondaryValue;
  final String tag;
  final StatusTagTone tone;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return BaseCard(
      backgroundColor: tokens.surface.withAlpha(235),
      borderColor: tokens.border.withAlpha(220),
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  eyebrow.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 1.0,
                    color: tokens.textSecondary,
                  ),
                ),
              ),
              StatusTag(label: tag, tone: tone),
            ],
          ),
          const SizedBox(height: 18),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 22),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _MetricCluster(label: 'Daily', value: value),
              _MetricCluster(label: 'Annualized', value: secondaryValue),
            ],
          ),
          if (footer != null) ...[const SizedBox(height: 20), footer!],
        ],
      ),
    );
  }
}

class _MetricCluster extends StatelessWidget {
  const _MetricCluster({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 6),
        MetricText(value, size: 22),
      ],
    );
  }
}
