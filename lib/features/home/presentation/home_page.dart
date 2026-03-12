import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/app/router/app_router.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/mock_trend_card.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(stablecoinsProvider.future),
      ref.refresh(yieldPoolsProvider.future),
      ref.refresh(healthProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stablecoinsAsync = ref.watch(stablecoinsProvider);
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final healthAsync = ref.watch(healthProvider);

    return AppPageScaffold(
      title: 'Stably',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Market Overview',
          child: stablecoinsAsync.when(
            data: (stablecoins) {
              final featured = stablecoins.isNotEmpty
                  ? stablecoins.first
                  : null;

              return HighlightPanel(
                title: featured == null
                    ? 'Stablecoin coverage is online.'
                    : '${featured.symbol} leads the tracked stablecoin set.',
                value: featured == null
                    ? '—'
                    : formatCurrency(featured.circulatingPeggedUsd),
                secondaryValue: featured == null
                    ? 'No data'
                    : '${featured.chains.length} chains',
                tag: 'Live',
                footer: Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: featured == null
                            ? 'Open discovery'
                            : 'Open ${featured.symbol}',
                        icon: CupertinoIcons.arrow_up_right,
                        onPressed: featured == null
                            ? null
                            : () => context.pushNamed(
                                AppRoute.stablecoinDetail.name,
                                pathParameters: {'id': featured.id},
                              ),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const AppHighlightPanelSkeleton(showFooter: true),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Coverage Snapshot',
          child: stablecoinsAsync.when(
            data: (stablecoins) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.shield_fill,
                        label: 'Fiat-backed',
                        value:
                            '${stablecoins.where((item) => item.pegMechanism == 'fiat-backed').length}',
                        caption:
                            'Tracked stablecoins with a fiat-backed mechanism.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: poolsAsync.when(
                        data: (pools) => InsightTile(
                          icon: CupertinoIcons.bolt_fill,
                          label: 'Yield pools',
                          value: '${pools.length}',
                          caption: 'Top APY-ranked pools from DefiLlama.',
                        ),
                        loading: () => const AppInsightTileSkeleton(),
                        error: (_, _) => const InsightTile(
                          icon: CupertinoIcons.bolt_fill,
                          label: 'Yield pools',
                          value: '—',
                          caption: 'Yield pool data unavailable.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InsightTile(
                        icon: CupertinoIcons.money_dollar_circle,
                        label: 'Circulating USD',
                        value: formatCurrency(
                          stablecoins.fold<double>(
                            0,
                            (sum, item) =>
                                sum + (item.circulatingPeggedUsd ?? 0),
                          ),
                        ),
                        caption:
                            'Combined circulating USD across loaded stablecoins.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: healthAsync.when(
                        data: (health) => InsightTile(
                          icon: CupertinoIcons.clock,
                          label: 'Last sync',
                          value: health.stablecoinsSyncedAt == null
                              ? '—'
                              : 'Ready',
                          caption:
                              health.stablecoinsSyncedAt ??
                              'No sync recorded yet.',
                        ),
                        loading: () => const AppInsightTileSkeleton(),
                        error: (_, _) => const InsightTile(
                          icon: CupertinoIcons.clock,
                          label: 'Last sync',
                          value: '—',
                          caption: 'Health status unavailable.',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const MockTrendCard(
                  title: 'Projected growth view',
                  subtitle:
                      'Static visual retained for now; this can later use historical series.',
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
          title: 'Top Yield Pools',
          child: poolsAsync.when(
            data: (pools) => _PoolList(
              pools: pools.take(2).toList(),
              stablecoins: stablecoinsAsync.maybeWhen(
                data: (items) => items,
                orElse: () => const <Stablecoin>[],
              ),
            ),
            loading: () => const AppListSkeleton(items: 2),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Top Stablecoins',
          child: stablecoinsAsync.when(
            data: (stablecoins) =>
                _StablecoinList(stablecoins: stablecoins.take(3).toList()),
            loading: () => const AppListSkeleton(items: 3),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        const SectionBlock(
          title: 'Risk Notes',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'This app compares and tracks only',
                description:
                    'No trades, deposits, or custody actions are performed inside the product.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Rates may move before the next refresh',
                description:
                    'Final pricing and campaign availability should always be checked on the target platform.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PoolList extends StatelessWidget {
  const _PoolList({required this.pools, required this.stablecoins});

  final List<YieldPool> pools;
  final List<Stablecoin> stablecoins;

  @override
  Widget build(BuildContext context) {
    if (pools.isEmpty) {
      return const AppEmptyState(
        title: 'No yield pools yet',
        description:
            'Run a backend sync, then refresh to load the current pool board.',
        icon: CupertinoIcons.chart_bar_alt_fill,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < pools.length; index++) ...[
          Builder(
            builder: (context) {
              final stablecoin = _matchStablecoin(pools[index], stablecoins);

              return OpportunityCard(
                icon: index == 0
                    ? CupertinoIcons.sparkles
                    : CupertinoIcons.shield,
                platform: pools[index].project,
                asset: '${pools[index].symbol} · ${pools[index].chain}',
                apy: formatPercent(pools[index].apy),
                summary: pools[index].poolMeta?.isNotEmpty == true
                    ? pools[index].poolMeta
                    : null,
                tags: [
                  pools[index].chain,
                  pools[index].symbol,
                  if ((pools[index].tvlUsd ?? 0) > 0)
                    formatCurrency(pools[index].tvlUsd),
                ],
                tone: (pools[index].apy ?? 0) >= 10
                    ? StatusTagTone.success
                    : StatusTagTone.info,
                onTap: stablecoin == null
                    ? null
                    : () => context.goNamed(
                        AppRoute.allocate.name,
                        queryParameters: {
                          'symbol': stablecoin.symbol,
                          'chain': pools[index].chain,
                        },
                      ),
              );
            },
          ),
          if (index != pools.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _StablecoinList extends StatelessWidget {
  const _StablecoinList({required this.stablecoins});

  final List<Stablecoin> stablecoins;

  @override
  Widget build(BuildContext context) {
    if (stablecoins.isEmpty) {
      return const AppEmptyState(
        title: 'No stablecoins yet',
        description:
            'Run a backend sync, then refresh to populate the stablecoin board.',
        icon: CupertinoIcons.money_dollar_circle,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < stablecoins.length; index++) ...[
          _StablecoinSummaryCard(stablecoin: stablecoins[index]),
          if (index != stablecoins.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StablecoinSummaryCard extends StatelessWidget {
  const _StablecoinSummaryCard({required this.stablecoin});

  final Stablecoin stablecoin;

  @override
  Widget build(BuildContext context) {
    return BaseCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stablecoin.symbol,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stablecoin.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(stablecoin.circulatingPeggedUsd),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  StatusTag(label: '${stablecoin.chains.length} chains'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: PillButton(
                  label: 'Detail',
                  icon: CupertinoIcons.doc_text_search,
                  compact: true,
                  isPrimary: false,
                  onPressed: () => context.pushNamed(
                    AppRoute.stablecoinDetail.name,
                    pathParameters: {'id': stablecoin.id},
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'Allocate',
                  icon: CupertinoIcons.chart_pie,
                  compact: true,
                  onPressed: () => context.goNamed(
                    AppRoute.allocate.name,
                    queryParameters: {'symbol': stablecoin.symbol},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Stablecoin? _matchStablecoin(YieldPool pool, List<Stablecoin> stablecoins) {
  for (final stablecoin in stablecoins) {
    if (stablecoin.symbol.toUpperCase() == pool.symbol.toUpperCase()) {
      return stablecoin;
    }
  }
  return null;
}
