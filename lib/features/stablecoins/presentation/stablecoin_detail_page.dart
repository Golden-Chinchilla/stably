import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/app/router/app_router.dart';
import 'package:stably_app/features/market/data/models/stablecoin_chain.dart';
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
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class StablecoinDetailPage extends ConsumerWidget {
  const StablecoinDetailPage({
    super.key,
    required this.stablecoinId,
    this.highlightedChain,
  });

  final String stablecoinId;
  final String? highlightedChain;

  Future<void> _refresh(WidgetRef ref) async {
    final detail = await ref.refresh(stablecoinDetailProvider(stablecoinId).future);
    final filter = (symbol: detail.stablecoin.symbol, chain: highlightedChain?.trim());
    ref.invalidate(yieldPoolsBySymbolAndChainProvider(filter));
    await ref.read(yieldPoolsBySymbolAndChainProvider(filter).future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(stablecoinDetailProvider(stablecoinId));

    return detailAsync.when(
      data: (detail) {
        final selectedChain = highlightedChain?.trim();
        final poolsAsync = ref.watch(
          yieldPoolsBySymbolAndChainProvider(
            (symbol: detail.stablecoin.symbol, chain: selectedChain),
          ),
        );
        final visibleChains = _sortChains(detail.chainData, selectedChain).take(6).toList();

        return AppPageScaffold(
          title: detail.stablecoin.symbol,
          subtitle: selectedChain == null
              ? '${detail.stablecoin.name} across tracked chains.'
              : '${detail.stablecoin.name} focused on $selectedChain.',
          onRefresh: () => _refresh(ref),
          children: [
            SectionBlock(
              title: 'Market Overview',
              subtitle: 'Identity, scale, and tracked chain coverage.',
              child: HighlightPanel(
                eyebrow: detail.stablecoin.pegType ?? 'stablecoin',
                title:
                    '${detail.stablecoin.symbol} is tracked on ${detail.stablecoin.chains.length} chains.',
                description: selectedChain == null
                    ? '${detail.stablecoin.name} is priced at ${detail.stablecoin.price?.toStringAsFixed(4) ?? '—'} with ${formatCurrency(detail.stablecoin.circulatingPeggedUsd)} in circulating USD.'
                    : '${detail.stablecoin.name} is priced at ${detail.stablecoin.price?.toStringAsFixed(4) ?? '—'} and the pool view is filtered to $selectedChain.',
                value: formatCurrency(detail.stablecoin.circulatingPeggedUsd),
                secondaryValue: '${detail.stablecoin.chains.length} chains',
                tag: detail.stablecoin.pegMechanism ?? 'Tracked',
                tone: _toneForPeg(detail.stablecoin.pegMechanism),
              ),
            ),
            SectionBlock(
              title: 'Core Profile',
              subtitle: 'Primary stablecoin attributes from DefiLlama.',
              child: InfoListCard(
                title: 'Profile fields',
                rows: [
                  (
                    label: 'Price',
                    value: detail.stablecoin.price?.toStringAsFixed(4) ?? '—',
                    hint: 'Latest price snapshot.'
                  ),
                  (
                    label: 'Peg mechanism',
                    value: detail.stablecoin.pegMechanism ?? 'Unknown',
                    hint: 'Mechanism classification from DefiLlama.'
                  ),
                  (
                    label: 'Price source',
                    value: detail.stablecoin.priceSource ?? 'Unknown',
                    hint: 'Upstream source for the displayed price.'
                  ),
                  (
                    label: 'Gecko ID',
                    value: detail.stablecoin.geckoId ?? '—',
                    hint: 'External asset mapping key.'
                  ),
                ],
              ),
            ),
            SectionBlock(
              title: 'Circulating USD Trend',
              subtitle: 'Current scale with day, week, and month snapshots.',
              child: InfoListCard(
                title: 'Scale snapshots',
                rows: [
                  (
                    label: 'Current',
                    value: formatCurrency(detail.stablecoin.circulatingPeggedUsd),
                    hint: 'Current circulating USD.'
                  ),
                  (
                    label: 'Previous day',
                    value: formatCurrency(
                      (detail.stablecoin.circulatingPrevDay['peggedUSD'] as num?)?.toDouble(),
                    ),
                    hint: 'Previous day snapshot.'
                  ),
                  (
                    label: 'Previous week',
                    value: formatCurrency(
                      (detail.stablecoin.circulatingPrevWeek['peggedUSD'] as num?)?.toDouble(),
                    ),
                    hint: 'Previous week snapshot.'
                  ),
                  (
                    label: 'Previous month',
                    value: formatCurrency(
                      (detail.stablecoin.circulatingPrevMonth['peggedUSD'] as num?)?.toDouble(),
                    ),
                    hint: 'Previous month snapshot.'
                  ),
                ],
              ),
            ),
            SectionBlock(
              title: 'Chain Coverage',
              subtitle: selectedChain == null
                  ? 'Filter the detail view by chain or review the largest chain slices.'
                  : 'The detail view is narrowed to one chain and its related pools.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      AppFilterChip(
                        label: 'All chains',
                        selected: selectedChain == null,
                        onTap: () => context.goNamed(
                          AppRoute.stablecoinDetail.name,
                          pathParameters: {'id': stablecoinId},
                        ),
                      ),
                      for (final chain in visibleChains.take(4))
                        AppFilterChip(
                          label: chain.chain,
                          selected: chain.chain == selectedChain,
                          onTap: () => context.goNamed(
                            AppRoute.stablecoinDetail.name,
                            pathParameters: {'id': stablecoinId},
                            queryParameters: {'chain': chain.chain},
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (var index = 0; index < visibleChains.length; index++) ...[
                        _ChainRowCard(
                          stablecoinId: stablecoinId,
                          chain: visibleChains[index],
                          highlighted: visibleChains[index].chain == selectedChain,
                        ),
                        if (index != visibleChains.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SectionBlock(
              title: 'Related Yield Pools',
              subtitle: selectedChain == null
                  ? 'Top tracked pools using this stablecoin symbol.'
                  : 'Top tracked pools using this stablecoin symbol on $selectedChain.',
              child: poolsAsync.when(
                data: (pools) {
                  if (pools.isEmpty) {
                    return AppEmptyState(
                      title: 'No related yield pools',
                      description: selectedChain == null
                          ? 'There are no tracked pools for this stablecoin symbol right now.'
                          : 'There are no tracked pools for this stablecoin symbol on $selectedChain right now.',
                      icon: CupertinoIcons.link,
                      actionLabel: 'Retry',
                      onAction: () => _refresh(ref),
                    );
                  }

                  final visiblePools = pools.take(3).toList();
                  return Column(
                    children: [
                      for (var index = 0; index < visiblePools.length; index++) ...[
                        OpportunityCard(
                          icon: CupertinoIcons.sparkles,
                          platform: visiblePools[index].project,
                          asset: '${visiblePools[index].symbol} · ${visiblePools[index].chain}',
                          apy: formatPercent(visiblePools[index].apy),
                          summary: visiblePools[index].poolMeta?.isNotEmpty == true
                              ? visiblePools[index].poolMeta!
                              : 'Tracked yield pool currently linked to this stablecoin symbol.',
                          tags: [
                            visiblePools[index].chain,
                            visiblePools[index].symbol,
                            if ((visiblePools[index].tvlUsd ?? 0) > 0)
                              formatCurrency(visiblePools[index].tvlUsd),
                          ],
                          tone: (visiblePools[index].apy ?? 0) >= 10
                              ? StatusTagTone.success
                              : StatusTagTone.info,
                          onTap: selectedChain == visiblePools[index].chain
                              ? null
                              : () => context.goNamed(
                                    AppRoute.stablecoinDetail.name,
                                    pathParameters: {'id': stablecoinId},
                                    queryParameters: {'chain': visiblePools[index].chain},
                                  ),
                        ),
                        if (index != visiblePools.length - 1) const SizedBox(height: 16),
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
          ],
        );
      },
      loading: () => const _DetailStateScaffold(
        child: Column(
          children: [
            AppHighlightPanelSkeleton(),
            SizedBox(height: 24),
            AppInfoListSkeleton(rows: 4),
            SizedBox(height: 24),
            AppInfoListSkeleton(rows: 4),
            SizedBox(height: 24),
            AppListSkeleton(items: 3),
          ],
        ),
      ),
      error: (error, _) => _DetailStateScaffold(
        child: AsyncSectionState.error(
          message: AsyncSectionState.presentError(error),
        ),
      ),
    );
  }
}

class _DetailStateScaffold extends StatelessWidget {
  const _DetailStateScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Stablecoin',
      subtitle: 'Loading stablecoin detail from the backend.',
      children: [child],
    );
  }
}

class _ChainRowCard extends StatelessWidget {
  const _ChainRowCard({
    required this.stablecoinId,
    required this.chain,
    this.highlighted = false,
  });

  final String stablecoinId;
  final StablecoinChain chain;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AppInteractiveCard(
      onTap: highlighted
          ? null
          : () => context.goNamed(
                AppRoute.stablecoinDetail.name,
                pathParameters: {'id': stablecoinId},
                queryParameters: {'chain': chain.chain},
              ),
      child: BaseCard(
        backgroundColor: highlighted
            ? Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(120)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        chain.chain,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (highlighted) ...[
                        const SizedBox(width: 8),
                        const StatusTag(
                          label: 'Focused',
                          tone: StatusTagTone.info,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Circulating USD · day ${formatCurrency((chain.circulatingPrevDay['peggedUSD'] as num?)?.toDouble())} · week ${formatCurrency((chain.circulatingPrevWeek['peggedUSD'] as num?)?.toDouble())}',
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
                  formatCurrency(chain.currentPeggedUsd),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                AppFilterChip(
                  label: highlighted ? 'Focused chain' : 'Focus chain',
                  selected: highlighted,
                  icon: CupertinoIcons.arrow_branch,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

StatusTagTone _toneForPeg(String? pegMechanism) {
  return switch (pegMechanism) {
    'fiat-backed' => StatusTagTone.success,
    'crypto-backed' => StatusTagTone.info,
    'algorithmic' => StatusTagTone.warning,
    _ => StatusTagTone.neutral,
  };
}

List<StablecoinChain> _sortChains(List<StablecoinChain> chains, String? highlightedChain) {
  final sorted = [...chains];
  sorted.sort((left, right) {
    if (highlightedChain != null) {
      if (left.chain == highlightedChain && right.chain != highlightedChain) {
        return -1;
      }
      if (right.chain == highlightedChain && left.chain != highlightedChain) {
        return 1;
      }
    }
    return (right.currentPeggedUsd ?? 0).compareTo(left.currentPeggedUsd ?? 0);
  });
  return sorted;
}
