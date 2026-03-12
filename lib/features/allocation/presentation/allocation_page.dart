import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/allocation_split_card.dart';
import 'package:stably_app/shared/widgets/app_amount_field.dart';
import 'package:stably_app/shared/widgets/app_bottom_sheet_picker_field.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_filter_chip.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_segmented_control.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/app_stepper_field.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class AllocationPage extends ConsumerStatefulWidget {
  const AllocationPage({super.key, this.initialSymbol, this.initialChain});

  final String? initialSymbol;
  final String? initialChain;

  @override
  ConsumerState<AllocationPage> createState() => _AllocationPageState();
}

class _AllocationPageState extends ConsumerState<AllocationPage> {
  late final TextEditingController _capitalController;
  String? _selectedSymbol;
  String? _selectedChain;
  _AllocationStrategy _strategy = _AllocationStrategy.balanced;
  int _maxPools = 3;
  double _minTvlUsd = 1000000;

  @override
  void initState() {
    super.initState();
    _capitalController = TextEditingController(text: '10000');
    _selectedSymbol = widget.initialSymbol;
    _selectedChain = widget.initialChain;
    _capitalController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant AllocationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSymbol != widget.initialSymbol ||
        oldWidget.initialChain != widget.initialChain) {
      _selectedSymbol = widget.initialSymbol;
      _selectedChain = widget.initialChain;
    }
  }

  @override
  void dispose() {
    _capitalController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.refresh(yieldPoolsProvider.future),
      ref.refresh(stablecoinsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final stablecoinsAsync = ref.watch(stablecoinsProvider);

    return AppPageScaffold(
      title: 'Allocation',
      subtitle:
          'Build an allocation using live yield pools, explicit filters, and a transparent scoring model.',
      onRefresh: _refresh,
      children: [
        SectionBlock(
          title: 'Allocation Overview',
          subtitle:
              'Current plan status based on your live inputs and constraints.',
          child: _buildOverview(stablecoinsAsync, poolsAsync),
        ),
        SectionBlock(
          title: 'Scenario Inputs',
          subtitle:
              'Set capital, stablecoin, chain scope, pool count, and selection strategy.',
          trailing: PillButton(
            label: 'Refresh',
            icon: CupertinoIcons.arrow_clockwise,
            onPressed: _refresh,
          ),
          child: _buildInputs(stablecoinsAsync, poolsAsync),
        ),
        SectionBlock(
          title: 'Suggested Allocation',
          subtitle:
              'A constrained plan built from live pools that match your selected scope.',
          child: _buildSuggestedAllocation(stablecoinsAsync, poolsAsync),
        ),
        SectionBlock(
          title: 'Plan Notes',
          subtitle:
              'Explain why pools were selected and what tradeoffs the current plan makes.',
          child: _buildPlanNotes(stablecoinsAsync, poolsAsync),
        ),
      ],
    );
  }

  Widget _buildOverview(
    AsyncValue<List<Stablecoin>> stablecoinsAsync,
    AsyncValue<List<YieldPool>> poolsAsync,
  ) {
    return stablecoinsAsync.when(
      data: (stablecoins) => poolsAsync.when(
        data: (pools) {
          _syncSelection(stablecoins, pools);
          final capital = _capital;
          final plan = _derivePlan(
            pools: pools,
            stablecoins: stablecoins,
            capital: capital,
          );

          return HighlightPanel(
            eyebrow: 'Allocation',
            title: plan.rows.isEmpty
                ? 'No plan matches the current constraints.'
                : 'Allocate across ${plan.rows.length} live yield pools with a ${_strategy.label.toLowerCase()} bias.',
            description: plan.rows.isEmpty
                ? 'Adjust stablecoin, chain scope, minimum TVL, or pool count to widen the selection set.'
                : 'The plan ranks eligible pools using APY and TVL, then distributes capital across the strongest matches instead of relying on a single pool.',
            value: formatCurrency(capital),
            secondaryValue: formatPercent(plan.blendedApy),
            tag: plan.rows.isEmpty ? 'No plan' : _strategy.label,
            tone: StatusTagTone.info,
          );
        },
        loading: () => const AppHighlightPanelSkeleton(),
        error: (error, _) => AsyncSectionState.error(
          message: AsyncSectionState.presentError(error),
          onRetry: _refresh,
        ),
      ),
      loading: () => const AppHighlightPanelSkeleton(),
      error: (error, _) => AsyncSectionState.error(
        message: AsyncSectionState.presentError(error),
        onRetry: _refresh,
      ),
    );
  }

  Widget _buildInputs(
    AsyncValue<List<Stablecoin>> stablecoinsAsync,
    AsyncValue<List<YieldPool>> poolsAsync,
  ) {
    return stablecoinsAsync.when(
      data: (stablecoins) => poolsAsync.when(
        data: (pools) {
          _syncSelection(stablecoins, pools);
          final availableChains = _availableChains(pools);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AllocationInputCard(
                capitalController: _capitalController,
                strategy: _strategy,
                maxPools: _maxPools,
                minTvlUsd: _minTvlUsd,
                onStrategyChanged: (value) => setState(() => _strategy = value),
                onMaxPoolsChanged: (value) => setState(() => _maxPools = value),
                onMinTvlChanged: (value) => setState(() => _minTvlUsd = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Stablecoins',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final stablecoin in stablecoins.take(8))
                    AppFilterChip(
                      label: stablecoin.symbol,
                      selected: _selectedSymbol == stablecoin.symbol,
                      onTap: () => setState(() {
                        _selectedSymbol = stablecoin.symbol;
                        _selectedChain = null;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Chain scope',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppFilterChip(
                    label: 'All chains',
                    selected: _selectedChain == null,
                    onTap: () => setState(() => _selectedChain = null),
                  ),
                  for (final chain in availableChains.take(8))
                    AppFilterChip(
                      label: chain,
                      selected: _selectedChain == chain,
                      onTap: () => setState(() => _selectedChain = chain),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.square_stack_fill,
                      label: 'Stablecoins',
                      value: '${stablecoins.length}',
                      caption: 'Available stablecoins from the backend.',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InsightTile(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      label: 'Eligible pools',
                      value: '${_eligiblePools(pools).length}',
                      caption:
                          'Pools that match the current filters before ranking.',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Column(
          children: [
            AppMetricCardSkeleton(),
            SizedBox(height: 16),
            AppListSkeleton(items: 2),
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
          onRetry: _refresh,
        ),
      ),
      loading: () => const Column(
        children: [
          AppMetricCardSkeleton(),
          SizedBox(height: 16),
          AppListSkeleton(items: 2),
        ],
      ),
      error: (error, _) => AsyncSectionState.error(
        message: AsyncSectionState.presentError(error),
        onRetry: _refresh,
      ),
    );
  }

  Widget _buildSuggestedAllocation(
    AsyncValue<List<Stablecoin>> stablecoinsAsync,
    AsyncValue<List<YieldPool>> poolsAsync,
  ) {
    return stablecoinsAsync.when(
      data: (stablecoins) => poolsAsync.when(
        data: (pools) {
          _syncSelection(stablecoins, pools);
          final plan = _derivePlan(
            pools: pools,
            stablecoins: stablecoins,
            capital: _capital,
          );

          if (plan.rows.isEmpty) {
            return AppEmptyState(
              title: 'No allocation plan yet',
              description:
                  'No live yield pools match the selected stablecoin, chain scope, or minimum TVL.',
              icon: CupertinoIcons.chart_pie,
              actionLabel: 'Reset chain scope',
              onAction: () => setState(() => _selectedChain = null),
            );
          }

          return Column(
            children: [
              AllocationSplitCard(rows: plan.splitRows),
              const SizedBox(height: 16),
              PlaceholderMetricCard(
                label: 'Estimated annual carry',
                value: formatCurrency(plan.estimatedAnnualCarry),
                caption:
                    'Directional estimate derived from the weighted APY of the selected live pools.',
                tag: '${plan.rows.length} pools',
                tone: StatusTagTone.success,
              ),
              const SizedBox(height: 16),
              InfoListCard(title: 'Allocation lines', rows: plan.infoRows),
              const SizedBox(height: 16),
              Column(
                children: [
                  for (var index = 0; index < plan.rows.length; index++) ...[
                    OpportunityCard(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      platform: plan.rows[index].pool.project,
                      asset:
                          '${plan.rows[index].pool.symbol} · ${plan.rows[index].pool.chain}',
                      apy: formatPercent(plan.rows[index].pool.apy),
                      summary:
                          '${plan.rows[index].percent}% allocation · score ${plan.rows[index].score.toStringAsFixed(2)} · TVL ${formatCurrency(plan.rows[index].pool.tvlUsd)}',
                      tags: [
                        formatCurrency(plan.rows[index].amount),
                        plan.rows[index].pool.symbol,
                        plan.rows[index].pool.chain,
                      ],
                      tone: StatusTagTone.info,
                    ),
                    if (index != plan.rows.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
            ],
          );
        },
        loading: () => const Column(
          children: [
            AppMetricCardSkeleton(),
            SizedBox(height: 16),
            AppInfoListSkeleton(rows: 3),
            SizedBox(height: 16),
            AppListSkeleton(items: 3),
          ],
        ),
        error: (error, _) => AsyncSectionState.error(
          message: AsyncSectionState.presentError(error),
          onRetry: _refresh,
        ),
      ),
      loading: () => const AppListSkeleton(items: 3),
      error: (error, _) => AsyncSectionState.error(
        message: AsyncSectionState.presentError(error),
        onRetry: _refresh,
      ),
    );
  }

  Widget _buildPlanNotes(
    AsyncValue<List<Stablecoin>> stablecoinsAsync,
    AsyncValue<List<YieldPool>> poolsAsync,
  ) {
    return stablecoinsAsync.when(
      data: (stablecoins) => poolsAsync.when(
        data: (pools) {
          _syncSelection(stablecoins, pools);
          final plan = _derivePlan(
            pools: pools,
            stablecoins: stablecoins,
            capital: _capital,
          );
          final topRow = plan.rows.isEmpty ? null : plan.rows.first;

          return Column(
            children: [
              RiskNoticeCard(
                title: topRow == null
                    ? 'No eligible lead pool'
                    : 'Lead pool: ${topRow.pool.project} on ${topRow.pool.chain}',
                description: topRow == null
                    ? 'Relax the current filters to widen the live pool set.'
                    : 'The lead pool ranks first under the current ${_strategy.label.toLowerCase()} strategy, but capital is still distributed across multiple pools to reduce concentration.',
                tone: StatusTagTone.info,
              ),
              const SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Strategy changes scoring, not the source data',
                description:
                    'Yield-first rewards higher APY, liquidity-first rewards deeper TVL, and balanced keeps both in scope. The page remains fully driven by the same live pool board.',
                tone: StatusTagTone.success,
              ),
              const SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Minimum TVL is an explicit constraint',
                description:
                    'Pools under ${formatCurrency(_minTvlUsd)} are filtered out before ranking so smaller pools do not dominate the plan solely through headline APY.',
                tone: StatusTagTone.warning,
              ),
            ],
          );
        },
        loading: () => const AppListSkeleton(items: 3),
        error: (error, _) => AsyncSectionState.error(
          message: AsyncSectionState.presentError(error),
          onRetry: _refresh,
        ),
      ),
      loading: () => const AppListSkeleton(items: 3),
      error: (error, _) => AsyncSectionState.error(
        message: AsyncSectionState.presentError(error),
        onRetry: _refresh,
      ),
    );
  }

  double get _capital {
    final parsed = double.tryParse(_capitalController.text.trim());
    if (parsed == null || parsed <= 0) {
      return 10000;
    }
    return parsed;
  }

  void _syncSelection(List<Stablecoin> stablecoins, List<YieldPool> pools) {
    if (stablecoins.isEmpty) {
      _selectedSymbol = null;
      _selectedChain = null;
      return;
    }

    _selectedSymbol ??= stablecoins.first.symbol;

    final hasSymbol = stablecoins.any((item) => item.symbol == _selectedSymbol);
    if (!hasSymbol) {
      _selectedSymbol = stablecoins.first.symbol;
      _selectedChain = null;
    }

    final chains = _availableChains(pools);
    if (_selectedChain != null && !chains.contains(_selectedChain)) {
      _selectedChain = null;
    }
  }

  List<String> _availableChains(List<YieldPool> pools) {
    final chains = _eligiblePools(
      pools,
      ignoreChain: true,
    ).map((pool) => pool.chain).toSet().toList()..sort();
    return chains;
  }

  List<YieldPool> _eligiblePools(
    List<YieldPool> pools, {
    bool ignoreChain = false,
  }) {
    final selectedSymbol = _selectedSymbol;
    if (selectedSymbol == null) {
      return const [];
    }

    return pools.where((pool) {
      final symbolMatches =
          pool.symbol.toUpperCase() == selectedSymbol.toUpperCase();
      final chainMatches =
          ignoreChain || _selectedChain == null || pool.chain == _selectedChain;
      final hasApy = (pool.apy ?? 0) > 0;
      final hasTvl = (pool.tvlUsd ?? 0) >= _minTvlUsd;
      return symbolMatches && chainMatches && hasApy && hasTvl;
    }).toList();
  }

  _AllocationPlan _derivePlan({
    required List<YieldPool> pools,
    required List<Stablecoin> stablecoins,
    required double capital,
  }) {
    final eligible = _eligiblePools(pools);
    if (eligible.isEmpty) {
      return const _AllocationPlan(
        rows: [],
        splitRows: [],
        infoRows: [],
        estimatedAnnualCarry: 0,
        blendedApy: 0,
      );
    }

    final ranked = [...eligible]
      ..sort((a, b) => _scorePool(b).compareTo(_scorePool(a)));
    final selected = ranked.take(_maxPools).toList();

    final totalScore = selected.fold<double>(
      0,
      (sum, pool) => sum + _scorePool(pool),
    );
    if (totalScore <= 0) {
      return const _AllocationPlan(
        rows: [],
        splitRows: [],
        infoRows: [],
        estimatedAnnualCarry: 0,
        blendedApy: 0,
      );
    }

    final rows = <_AllocationRow>[];
    final splitRows = <({String label, String value, Color color, int flex})>[];
    final infoRows = <({String label, String value, String hint})>[];
    const colors = [
      Color(0xFFD9A05B),
      Color(0xFF5E93A5),
      Color(0xFF4A5D23),
      Color(0xFFB2E159),
      Color(0xFF7A8D4E),
    ];

    var estimatedAnnualCarry = 0.0;

    for (var index = 0; index < selected.length; index++) {
      final pool = selected[index];
      final score = _scorePool(pool);
      final weight = score / totalScore;
      final amount = capital * weight;
      final percent = math.max((weight * 100).round(), 1);
      final color = colors[index % colors.length];
      estimatedAnnualCarry += amount * ((pool.apy ?? 0) / 100);

      rows.add(
        _AllocationRow(
          pool: pool,
          amount: amount,
          percent: percent,
          color: color,
          score: score,
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
        hint:
            'APY ${formatPercent(pool.apy)} · TVL ${formatCurrency(pool.tvlUsd)} · ${pool.symbol}',
      ));
    }

    final blendedApy = capital == 0
        ? 0.0
        : (estimatedAnnualCarry / capital) * 100;

    return _AllocationPlan(
      rows: rows,
      splitRows: splitRows,
      infoRows: infoRows,
      estimatedAnnualCarry: estimatedAnnualCarry,
      blendedApy: blendedApy,
    );
  }

  double _scorePool(YieldPool pool) {
    final apy = math.max(pool.apy ?? 0, 0);
    final tvlScore = math.log((pool.tvlUsd ?? 0) + 1);

    return switch (_strategy) {
      _AllocationStrategy.yieldFirst => (apy * 0.8) + (tvlScore * 0.2),
      _AllocationStrategy.liquidityFirst => (apy * 0.35) + (tvlScore * 0.65),
      _AllocationStrategy.balanced => (apy * 0.6) + (tvlScore * 0.4),
    };
  }
}

class _AllocationInputCard extends StatelessWidget {
  const _AllocationInputCard({
    required this.capitalController,
    required this.strategy,
    required this.maxPools,
    required this.minTvlUsd,
    required this.onStrategyChanged,
    required this.onMaxPoolsChanged,
    required this.onMinTvlChanged,
  });

  final TextEditingController capitalController;
  final _AllocationStrategy strategy;
  final int maxPools;
  final double minTvlUsd;
  final ValueChanged<_AllocationStrategy> onStrategyChanged;
  final ValueChanged<int> onMaxPoolsChanged;
  final ValueChanged<double> onMinTvlChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allocation controls', style: theme.textTheme.titleMedium),
          const SizedBox(height: 14),
          AppAmountField(
            controller: capitalController,
            label: 'Capital (USD)',
            placeholder: '10000',
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Strategy', style: theme.textTheme.titleSmall),
          const SizedBox(height: 10),
          AppSegmentedControl<_AllocationStrategy>(
            value: strategy,
            options: [
              for (final option in _AllocationStrategy.values)
                (value: option, label: option.label),
            ],
            onChanged: onStrategyChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppStepperField(
                  label: 'Max pools',
                  value: '$maxPools',
                  onDecrease: maxPools > 2
                      ? () => onMaxPoolsChanged(maxPools - 1)
                      : null,
                  onIncrease: maxPools < 5
                      ? () => onMaxPoolsChanged(maxPools + 1)
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppBottomSheetPickerField<double>(
                  label: 'Minimum TVL',
                  value: minTvlUsd,
                  displayText: minTvlUsd == 0
                      ? 'No floor'
                      : formatCurrency(minTvlUsd),
                  options: [
                    (value: 0.0, label: 'No floor'),
                    (value: 1000000.0, label: formatCurrency(1000000)),
                    (value: 10000000.0, label: formatCurrency(10000000)),
                  ],
                  onChanged: onMinTvlChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _AllocationStrategy {
  balanced('Balanced'),
  yieldFirst('Yield-first'),
  liquidityFirst('Liquidity-first');

  const _AllocationStrategy(this.label);

  final String label;
}

class _AllocationPlan {
  const _AllocationPlan({
    required this.rows,
    required this.splitRows,
    required this.infoRows,
    required this.estimatedAnnualCarry,
    required this.blendedApy,
  });

  final List<_AllocationRow> rows;
  final List<({String label, String value, Color color, int flex})> splitRows;
  final List<({String label, String value, String hint})> infoRows;
  final double estimatedAnnualCarry;
  final double blendedApy;
}

class _AllocationRow {
  const _AllocationRow({
    required this.pool,
    required this.amount,
    required this.percent,
    required this.color,
    required this.score,
  });

  final YieldPool pool;
  final double amount;
  final int percent;
  final Color color;
  final double score;
}
