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
import 'package:stably_app/shared/widgets/app_filter_chip.dart';
import 'package:stably_app/shared/widgets/app_interactive_card.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

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
      title: 'Yield Discovery',
      subtitle: 'Scan tracked stablecoins and the highest APY yield pools.',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Discovery Overview',
          subtitle: 'Top yield pool signal from the current market set.',
          child: poolsAsync.when(
            data: (pools) {
              final topPool = pools.isNotEmpty ? pools.first : null;

              return HighlightPanel(
                eyebrow: 'Yield pools',
                title: topPool == null
                    ? 'Yield pool coverage is online.'
                    : '${topPool.project} leads the tracked yield pool board.',
                description: topPool == null
                    ? 'No yield pools are available yet. Run a backend sync and refresh the page.'
                    : 'Current lead pool is ${topPool.symbol} on ${topPool.chain}. Use it as a first pass before comparing stablecoin coverage and chain context.',
                value: topPool == null ? '—' : formatPercent(topPool.apy),
                secondaryValue: '${pools.length} pools',
                tag: 'Live',
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
          title: 'Stablecoin Filters',
          subtitle: 'Open a stablecoin detail view directly from the tracked set.',
          child: stablecoinsAsync.when(
            data: (stablecoins) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stablecoin in stablecoins.take(5))
                  _StablecoinChip(stablecoin: stablecoin),
              ],
            ),
            loading: () => const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppSkeletonBox(height: 28, width: 64, radius: 999),
                AppSkeletonBox(height: 28, width: 72, radius: 999),
                AppSkeletonBox(height: 28, width: 68, radius: 999),
                AppSkeletonBox(height: 28, width: 76, radius: 999),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Stablecoin Coverage',
          subtitle: 'Jump from discovery into stablecoin detail and chain coverage.',
          child: stablecoinsAsync.when(
            data: (stablecoins) => _StablecoinBoard(
              stablecoins: stablecoins.take(4).toList(),
            ),
            loading: () => const AppListSkeleton(items: 4),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        SectionBlock(
          title: 'Yield Pool Board',
          subtitle: 'Tracked yield pools ranked by APY, with stablecoin detail deep links.',
          child: poolsAsync.when(
            data: (pools) {
              if (pools.isEmpty) {
                return const AppEmptyState(
                  title: 'No yield pools yet',
                  description: 'Run a backend sync to populate the tracked yield pool board.',
                  icon: CupertinoIcons.search_circle,
                );
              }

              final topPool = pools.first;
              final baselinePool = pools.firstWhere(
                (pool) => pool.project.toLowerCase().contains('aave'),
                orElse: () => topPool,
              );

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.arrow_up_right_circle_fill,
                          label: 'Top APY',
                          value: formatPercent(topPool.apy),
                          caption: '${topPool.project} · ${topPool.symbol}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.cube_box_fill,
                          label: 'Baseline pool',
                          value: formatPercent(baselinePool.apy),
                          caption: '${baselinePool.project} · ${baselinePool.chain}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DiscoverPoolList(pools: pools.take(3).toList()),
                ],
              );
            },
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
                AppListSkeleton(items: 3),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: () => _refresh(ref),
            ),
          ),
        ),
        const SectionBlock(
          title: 'Research Notes',
          subtitle: 'Static notes remain until protocol metadata gets richer.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'CeFi campaigns can be capacity constrained',
                description:
                    'High APY exchange windows often apply only to a limited balance slice.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Synthetic dollars need closer review',
                description:
                    'Newer structures can offer higher yield, but risk is not directly comparable to simple fiat-backed stablecoins.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StablecoinChip extends StatelessWidget {
  const _StablecoinChip({required this.stablecoin});

  final Stablecoin stablecoin;

  @override
  Widget build(BuildContext context) {
    return AppFilterChip(
      label: stablecoin.symbol,
      onTap: () => context.pushNamed(
        AppRoute.stablecoinDetail.name,
        pathParameters: {'id': stablecoin.id},
      ),
    );
  }
}

class _StablecoinBoard extends StatelessWidget {
  const _StablecoinBoard({required this.stablecoins});

  final List<Stablecoin> stablecoins;

  @override
  Widget build(BuildContext context) {
    if (stablecoins.isEmpty) {
      return const AppEmptyState(
        title: 'No stablecoins yet',
        description: 'Run a backend sync to populate the tracked stablecoin board.',
        icon: CupertinoIcons.money_dollar_circle,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < stablecoins.length; index++) ...[
          _StablecoinBoardCard(stablecoin: stablecoins[index]),
          if (index != stablecoins.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StablecoinBoardCard extends StatelessWidget {
  const _StablecoinBoardCard({required this.stablecoin});

  final Stablecoin stablecoin;

  @override
  Widget build(BuildContext context) {
    return AppInteractiveCard(
      onTap: () => context.pushNamed(
        AppRoute.stablecoinDetail.name,
        pathParameters: {'id': stablecoin.id},
      ),
      child: BaseCard(
        child: Row(
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
      ),
    );
  }
}

class _DiscoverPoolList extends StatelessWidget {
  const _DiscoverPoolList({required this.pools});

  final List<YieldPool> pools;

  @override
  Widget build(BuildContext context) {
    final stablecoins = <String, Stablecoin>{};

    final inherited = ProviderScope.containerOf(context, listen: false)
        .read(stablecoinsProvider)
        .maybeWhen(
          data: (items) => items,
          orElse: () => const <Stablecoin>[],
        );

    for (final stablecoin in inherited) {
      stablecoins[stablecoin.symbol] = stablecoin;
    }

    return Column(
      children: [
        for (var index = 0; index < pools.length; index++) ...[
          OpportunityCard(
            icon: index == 0
                ? CupertinoIcons.sparkles
                : index == 1
                    ? CupertinoIcons.cube_box
                    : CupertinoIcons.flame,
            platform: pools[index].project,
            asset: '${pools[index].symbol} · ${pools[index].chain}',
            apy: formatPercent(pools[index].apy),
            summary: pools[index].poolMeta?.isNotEmpty == true
                ? pools[index].poolMeta!
                : 'Tracked yield pool synced from the backend pool board.',
            tags: [
              pools[index].chain,
              pools[index].symbol,
              if ((pools[index].tvlUsd ?? 0) > 0) formatCurrency(pools[index].tvlUsd),
            ],
            tone: (pools[index].apy ?? 0) >= 10 ? StatusTagTone.success : StatusTagTone.info,
            onTap: () {
              final stablecoin =
                  stablecoins[pools[index].symbol.toUpperCase()] ?? stablecoins[pools[index].symbol];
              if (stablecoin == null) {
                return;
              }

              context.pushNamed(
                AppRoute.stablecoinDetail.name,
                pathParameters: {'id': stablecoin.id},
                queryParameters: {'chain': pools[index].chain},
              );
            },
          ),
          if (index != pools.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}
