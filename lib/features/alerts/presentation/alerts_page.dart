import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/alerts/data/models/alert_rule.dart';
import 'package:stably_app/features/alerts/presentation/providers/alert_rule_providers.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/features/portfolio/presentation/providers/portfolio_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/alert_rule_card.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(alertRulesControllerProvider.future),
      ref.refresh(yieldPoolsProvider.future),
      ref.refresh(portfolioControllerProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rulesAsync = ref.watch(alertRulesControllerProvider);
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final portfolioAsync = ref.watch(portfolioControllerProvider);

    return AppPageScaffold(
      title: 'Alerts',
      subtitle: 'Local rule tracking with live pool and portfolio context.',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Premium alerting',
          subtitle: 'This hero now reflects local rules and live pool coverage.',
          child: rulesAsync.when(
            data: (rules) {
              final premiumLikeCount =
                  rules.where((rule) => rule.type != AlertRuleType.yieldBelow).length;

              return HighlightPanel(
                eyebrow: 'Signals',
                title: rules.isEmpty
                    ? 'No local alert rules yet.'
                    : 'Keep rates, promos, and portfolio drift under one quiet watchlist.',
                description: rules.isEmpty
                    ? 'Seed the page to create a first local set of alert rules.'
                    : 'Rules are stored locally, while current pool data provides context for what those rules are watching.',
                value: '${rules.length} active',
                secondaryValue: '$premiumLikeCount premium-like',
                tag: rules.isEmpty ? 'Empty' : 'Live',
                tone: StatusTagTone.warning,
              );
            },
            loading: () => const AppHighlightPanelSkeleton(),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Alert status',
          subtitle: 'This block combines local rules, live pools, and tracked positions.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PillButton(
                label: 'Load demo',
                icon: CupertinoIcons.arrow_down_doc,
                onPressed: () => ref.read(alertRulesControllerProvider.notifier).seedDemoRules(),
              ),
              const SizedBox(width: 8),
              PillButton(
                label: 'Clear',
                icon: CupertinoIcons.trash,
                isPrimary: false,
                onPressed: () => ref.read(alertRulesControllerProvider.notifier).clearRules(),
              ),
            ],
          ),
          child: rulesAsync.when(
            data: (rules) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.bell,
                        label: 'Threshold rules',
                        value:
                            '${rules.where((rule) => rule.type == AlertRuleType.yieldBelow).length}',
                        caption: 'Local yield-floor monitoring rules.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: portfolioAsync.when(
                        data: (positions) => InsightTile(
                          icon: CupertinoIcons.square_stack_3d_up_fill,
                          label: 'Tracked positions',
                          value: '${positions.length}',
                          caption: 'Portfolio entries that can trigger drift reminders.',
                        ),
                        loading: () => const AppInsightTileSkeleton(),
                        error: (_, _) => const InsightTile(
                          icon: CupertinoIcons.square_stack_3d_up_fill,
                          label: 'Tracked positions',
                          value: '—',
                          caption: 'Portfolio context unavailable.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                poolsAsync.when(
                  data: (pools) => PlaceholderMetricCard(
                    label: 'Monitored pool board',
                    value: '${pools.length} lanes',
                    caption: pools.isEmpty
                        ? 'No live pools loaded yet.'
                        : 'Current top monitored pool: ${pools.first.project} · ${formatPercent(pools.first.apy)}',
                    tag: 'Live',
                    tone: StatusTagTone.warning,
                  ),
                  loading: () => const AppMetricCardSkeleton(),
                  error: (error, _) => AsyncSectionState.error(
                    message: AsyncSectionState.presentError(error),
                    onRetry: () => _refresh(ref),
                  ),
                ),
              ],
            ),
            loading: () => const Column(
              children: [
                Row(
                  children: [
                    Expanded(child: AppInsightTileSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: AppInsightTileSkeleton()),
                  ],
                ),
                SizedBox(height: 16),
                AppMetricCardSkeleton(),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Configured rules',
          subtitle: 'Rules are now stored locally and can be seeded from the live pool board.',
          child: rulesAsync.when(
            data: (rules) {
              if (rules.isEmpty) {
                return AppEmptyState(
                  title: 'No alert rules yet',
                  description: 'Load demo rules to seed local alert tracking for this page.',
                  icon: CupertinoIcons.bell,
                  actionLabel: 'Load demo',
                  onAction: () => ref.read(alertRulesControllerProvider.notifier).seedDemoRules(),
                );
              }

              final pools = poolsAsync.maybeWhen(
                data: (items) => items,
                orElse: () => const <YieldPool>[],
              );

              return Column(
                children: [
                  for (var index = 0; index < rules.length; index++) ...[
                    AlertRuleCard(
                      title: rules[index].title,
                      description: _ruleDescription(rules[index], pools),
                      frequency: rules[index].frequency,
                      tone: _ruleTone(rules[index]),
                    ),
                    if (index != rules.length - 1) const SizedBox(height: 16),
                  ],
                ],
              );
            },
            loading: () => const AppListSkeleton(items: 3),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        const SectionBlock(
          title: 'Messaging principles',
          subtitle: 'The notification layer stays informative, selective, and compliant.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Alerts suggest reviews, not actions',
                description:
                    'The product surfaces information but does not execute transfers or recommendations.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Short-lived promos may expire before the user acts',
                description:
                    'Final availability should always be verified on the destination platform.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _ruleDescription(AlertRule rule, List<YieldPool> pools) {
  switch (rule.type) {
    case AlertRuleType.yieldBelow:
      return '${rule.description} Current threshold: ${rule.threshold?.toStringAsFixed(2) ?? '—'}%.';
    case AlertRuleType.newPromoWatch:
      final matched = pools.where((pool) => pool.symbol == rule.symbol).take(1).toList();
      if (matched.isEmpty) {
        return rule.description;
      }
      return '${rule.description} Current live context: ${matched.first.project} on ${matched.first.chain} at ${formatPercent(matched.first.apy)}.';
    case AlertRuleType.portfolioDrift:
      return rule.description;
  }
}

StatusTagTone _ruleTone(AlertRule rule) {
  return switch (rule.type) {
    AlertRuleType.yieldBelow => StatusTagTone.info,
    AlertRuleType.newPromoWatch => StatusTagTone.success,
    AlertRuleType.portfolioDrift => StatusTagTone.warning,
  };
}
