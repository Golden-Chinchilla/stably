import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/allocation_split_card.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AllocationPage extends ConsumerWidget {
  const AllocationPage({super.key});

  static const _scenarioCapital = 10000.0;

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(yieldPoolsProvider.future),
      ref.refresh(stablecoinsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final stablecoinsAsync = ref.watch(stablecoinsProvider);

    return AppPageScaffold(
      title: 'Smart Allocation',
      subtitle: 'A live sample allocation built from the current yield pool board.',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Optimizer preview',
          subtitle: 'The allocator hero now uses live pool coverage from the backend.',
          child: poolsAsync.when(
            data: (pools) {
              final topPools = _selectAllocationPools(pools);

              return HighlightPanel(
                eyebrow: 'Allocator',
                title: topPools.isEmpty
                    ? 'Allocation engine is connected.'
                    : 'Current sample plan uses ${topPools.length} live yield lanes.',
                description: topPools.isEmpty
                    ? 'No pools are available yet. Run a backend sync and refresh the page.'
                    : 'This sample plan ranks live pools, spreads capital across the strongest lanes, and keeps the recommendation readable enough for first-pass decision making.',
                value: '${topPools.length} buckets',
                secondaryValue: '${formatCurrency(_scenarioCapital)} scenario',
                tag: 'Live',
                tone: StatusTagTone.info,
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
          title: 'Scenario inputs',
          subtitle: 'This section uses live stablecoin and pool counts to frame the sample scenario.',
          trailing: PillButton(
            label: 'Refresh',
            icon: CupertinoIcons.arrow_clockwise,
            onPressed: () => _refresh(ref),
          ),
          child: stablecoinsAsync.when(
            data: (stablecoins) => Column(
              children: [
                PlaceholderMetricCard(
                  label: 'Scenario capital',
                  value: '${_scenarioCapital.toStringAsFixed(2)} USDC',
                  caption:
                      'Sample allocation amount used to make the live optimizer output comparable across sessions.',
                  tag: stablecoins.isEmpty ? 'No data' : stablecoins.first.symbol,
                  tone: StatusTagTone.info,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.square_stack_fill,
                        label: 'Tracked stablecoins',
                        value: '${stablecoins.length}',
                        caption: 'Top stablecoins currently loaded from the backend.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: poolsAsync.when(
                        data: (pools) => InsightTile(
                          icon: CupertinoIcons.chart_bar_alt_fill,
                          label: 'Output focus',
                          value: '${pools.length}',
                          caption: 'Top-ranked pools currently feeding the allocator.',
                        ),
                        loading: () => const AppInsightTileSkeleton(),
                        error: (_, _) => const InsightTile(
                          icon: CupertinoIcons.chart_bar_alt_fill,
                          label: 'Output focus',
                          value: '—',
                          caption: 'Pool data unavailable.',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            loading: () => const Column(
              children: [
                AppMetricCardSkeleton(),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: AppInsightTileSkeleton()),
                    SizedBox(width: 16),
                    Expanded(child: AppInsightTileSkeleton()),
                  ],
                ),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Suggested split',
          subtitle: 'This sample split uses live APY-ranked pools and a simple weighted allocation heuristic.',
          child: poolsAsync.when(
            data: (pools) {
              final allocation = _buildAllocationPlan(
                pools: _selectAllocationPools(pools),
                capital: _scenarioCapital,
              );

              if (allocation.rows.isEmpty) {
                return AppEmptyState(
                  title: 'No allocation inputs yet',
                  description: 'Refresh after syncing the backend to build a live allocation sample.',
                  icon: CupertinoIcons.chart_pie,
                  actionLabel: 'Refresh',
                  onAction: () => _refresh(ref),
                );
              }

              return Column(
                children: [
                  AllocationSplitCard(rows: allocation.splitRows),
                  const SizedBox(height: 16),
                  InfoListCard(
                    title: 'Allocation lanes',
                    rows: allocation.infoRows,
                  ),
                ],
              );
            },
            loading: () => const Column(
              children: [
                AppMetricCardSkeleton(),
                SizedBox(height: 16),
                AppInfoListSkeleton(rows: 3),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Why this mix',
          subtitle: 'The current sample explains the plan using live pool and stablecoin data.',
          child: poolsAsync.when(
            data: (pools) {
              final topPools = _selectAllocationPools(pools);
              final leadingPool = topPools.isNotEmpty ? topPools.first : null;

              return Column(
                children: [
                  RiskNoticeCard(
                    title: leadingPool == null
                        ? 'No live leading lane'
                        : 'Lead with ${leadingPool.project} on ${leadingPool.chain}',
                    description: leadingPool == null
                        ? 'The allocator needs at least one live pool before it can explain a plan.'
                        : 'The current sample puts the strongest live APY lane first, then spreads overflow across the next best routes rather than concentrating everything into one pool.',
                    tone: StatusTagTone.info,
                  ),
                  const SizedBox(height: 12),
                  RiskNoticeCard(
                    title: 'Use live pool depth as a sanity check',
                    description:
                        'APY alone is not enough. TVL and chain choice remain visible so the plan stays understandable and not purely yield-chasing.',
                    tone: StatusTagTone.success,
                  ),
                ],
              );
            },
            loading: () => const AppListSkeleton(items: 2),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
      ],
    );
  }
}

List<YieldPool> _selectAllocationPools(List<YieldPool> pools) {
  final preferred = pools
      .where((pool) => pool.symbol.toUpperCase().contains('USD'))
      .toList();

  final source = preferred.isNotEmpty ? preferred : pools;
  return source.take(3).toList();
}

_AllocationPlan _buildAllocationPlan({
  required List<YieldPool> pools,
  required double capital,
}) {
  if (pools.isEmpty) {
    return const _AllocationPlan(rows: [], splitRows: [], infoRows: []);
  }

  final scores = pools
      .map((pool) => math.max((pool.apy ?? 0) + 1, 1))
      .toList();
  final totalScore = scores.fold<double>(0, (sum, value) => sum + value);

  final rows = <_AllocationRow>[];
  final splitRows = <({String label, String value, Color color, int flex})>[];
  final infoRows = <({String label, String value, String hint})>[];
  const colors = [
    Color(0xFFD9A05B),
    Color(0xFF5E93A5),
    Color(0xFF4A5D23),
  ];

  for (var index = 0; index < pools.length; index++) {
    final pool = pools[index];
    final weight = totalScore == 0 ? 1 / pools.length : scores[index] / totalScore;
    final amount = capital * weight;
    final percent = math.max((weight * 100).round(), 1);
    final color = colors[index % colors.length];

    rows.add(
      _AllocationRow(
        pool: pool,
        amount: amount,
        percent: percent,
        color: color,
      ),
    );

    splitRows.add((
      label: pool.project,
      value: amount.toStringAsFixed(2),
      color: color,
      flex: percent,
    ));

    infoRows.add((
      label: '${pool.project} · ${pool.chain}',
      value: formatCurrency(amount),
      hint: 'APY ${formatPercent(pool.apy)} · TVL ${formatCurrency(pool.tvlUsd)} · ${pool.symbol}',
    ));
  }

  return _AllocationPlan(
    rows: rows,
    splitRows: splitRows,
    infoRows: infoRows,
  );
}

class _AllocationPlan {
  const _AllocationPlan({
    required this.rows,
    required this.splitRows,
    required this.infoRows,
  });

  final List<_AllocationRow> rows;
  final List<({String label, String value, Color color, int flex})> splitRows;
  final List<({String label, String value, String hint})> infoRows;
}

class _AllocationRow {
  const _AllocationRow({
    required this.pool,
    required this.amount,
    required this.percent,
    required this.color,
  });

  final YieldPool pool;
  final double amount;
  final int percent;
  final Color color;
}
