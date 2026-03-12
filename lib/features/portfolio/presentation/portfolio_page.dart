import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/features/portfolio/data/models/portfolio_position.dart';
import 'package:stably_app/features/portfolio/presentation/providers/portfolio_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/info_list_card.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/placeholder_metric_card.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(portfolioControllerProvider.future),
      ref.refresh(yieldPoolsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioControllerProvider);
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final livePools = poolsAsync.maybeWhen(
      data: (pools) => pools,
      orElse: () => const <YieldPool>[],
    );

    return AppPageScaffold(
      title: 'Portfolio Tracker',
      subtitle: 'A local-first ledger backed by manual positions and live pool context.',
      onRefresh: () => _refresh(ref),
      children: [
        SectionBlock(
          title: 'Portfolio summary',
          subtitle: 'This summary now reflects locally stored positions.',
          child: portfolioAsync.when(
            data: (positions) {
              final summary = _buildSummary(positions, livePools);

              return HighlightPanel(
                eyebrow: 'Tracker',
                title: positions.isEmpty
                    ? 'No local positions yet.'
                    : 'Track ${positions.length} local positions with live APY context.',
                description: positions.isEmpty
                    ? 'Seed the page from live pools to create a first local portfolio snapshot.'
                    : 'This view stays local-first while using the current pool board to contextualize your tracked positions.',
                value: formatCurrency(summary.totalAmount),
                secondaryValue: formatCurrency(summary.estimatedAnnualCarry),
                tag: positions.isEmpty ? 'Empty' : 'Tracking',
                footer: Row(
                  children: [
                    Expanded(
                      child: PillButton(
                        label: positions.isEmpty ? 'Load demo' : 'Reload demo',
                        icon: CupertinoIcons.arrow_down_doc,
                        onPressed: () => ref
                            .read(portfolioControllerProvider.notifier)
                            .seedDemoFromLivePools(),
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
          title: 'Performance shell',
          subtitle: 'Manual positions are combined with current APY snapshots for a lightweight tracker.',
          trailing: PillButton(
            label: 'Clear',
            icon: CupertinoIcons.trash,
            isPrimary: false,
            onPressed: () => ref.read(portfolioControllerProvider.notifier).clearAll(),
          ),
          child: portfolioAsync.when(
            data: (positions) {
              final summary = _buildSummary(positions, livePools);
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.money_dollar_circle,
                          label: 'Blended yield',
                          value: formatPercent(summary.blendedApy),
                          caption: 'Weighted from the locally tracked position mix.',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.clock,
                          label: 'Positions',
                          value: '${positions.length}',
                          caption: 'Locally saved ledger entries.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PlaceholderMetricCard(
                    label: 'Simulated annual carry',
                    value: '${summary.estimatedAnnualCarry.toStringAsFixed(2)} USDC',
                    caption: 'Directional estimate using the current APY attached to each local position.',
                    tag: 'Local',
                    tone: StatusTagTone.success,
                  ),
                  const SizedBox(height: 16),
                  InfoListCard(
                    title: 'Position mix',
                    rows: [
                      (
                        label: 'Tracked capital',
                        value: formatCurrency(summary.totalAmount),
                        hint: 'Total manually recorded capital.'
                      ),
                      (
                        label: 'Estimated annual carry',
                        value: formatCurrency(summary.estimatedAnnualCarry),
                        hint: 'Simple estimate from amount × APY.'
                      ),
                      (
                        label: 'Highest live APY',
                        value: formatPercent(summary.highestApy),
                        hint: 'Current highest APY among the tracked positions.'
                      ),
                    ],
                  ),
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
          title: 'Recorded positions',
          subtitle: 'Positions are local-first and can be seeded from the live pool board.',
          child: portfolioAsync.when(
            data: (positions) {
              if (positions.isEmpty) {
                return AppEmptyState(
                  title: 'No local positions yet',
                  description: 'Load a demo portfolio to seed the tracker with local positions.',
                  icon: CupertinoIcons.briefcase,
                  actionLabel: 'Load demo',
                  onAction: () => ref
                      .read(portfolioControllerProvider.notifier)
                      .seedDemoFromLivePools(),
                );
              }

              final pools = livePools;
              return Column(
                children: [
                  for (var index = 0; index < positions.length; index++) ...[
                    _PortfolioPositionCard(
                      position: positions[index],
                      livePool: _findMatchingPool(positions[index], pools),
                    ),
                    if (index != positions.length - 1) const SizedBox(height: 16),
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
          title: 'Tracker notes',
          subtitle: 'The portfolio page still reinforces local-first and manual-accounting boundaries.',
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'Balances are manually recorded',
                description:
                    'The app does not read exchange accounts or on-chain wallets for this product version.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'Simulated growth is directional',
                description:
                    'Actual outcomes depend on changing rates, reward mechanics, and real user actions.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PortfolioPositionCard extends StatelessWidget {
  const _PortfolioPositionCard({
    required this.position,
    this.livePool,
  });

  final PortfolioPosition position;
  final YieldPool? livePool;

  @override
  Widget build(BuildContext context) {
    final apy = livePool?.apy ?? position.apy;

    return OpportunityCard(
      icon: livePool == null ? CupertinoIcons.archivebox : CupertinoIcons.chart_bar_alt_fill,
      platform: position.platform,
      asset: '${position.symbol} · ${position.chain}',
      apy: formatPercent(apy),
      summary: livePool == null
          ? 'Local position stored on device. No matching live pool context found.'
          : 'Local position matched against the current live pool board for updated APY context.',
      tags: [
        formatCurrency(position.amount),
        position.symbol,
        position.chain,
      ],
      tone: livePool == null ? StatusTagTone.warning : StatusTagTone.info,
    );
  }
}

class _PortfolioSummary {
  const _PortfolioSummary({
    required this.totalAmount,
    required this.estimatedAnnualCarry,
    required this.blendedApy,
    required this.highestApy,
  });

  final double totalAmount;
  final double estimatedAnnualCarry;
  final double blendedApy;
  final double highestApy;
}

_PortfolioSummary _buildSummary(
  List<PortfolioPosition> positions,
  List<YieldPool> pools,
) {
  if (positions.isEmpty) {
    return const _PortfolioSummary(
      totalAmount: 0,
      estimatedAnnualCarry: 0,
      blendedApy: 0,
      highestApy: 0,
    );
  }

  final totalAmount = positions.fold<double>(0, (sum, item) => sum + item.amount);
  var estimatedAnnualCarry = 0.0;
  var highestApy = 0.0;

  for (final position in positions) {
    final livePool = _findMatchingPool(position, pools);
    final effectiveApy = livePool?.apy ?? position.apy;
    estimatedAnnualCarry += position.amount * (effectiveApy / 100);
    highestApy = effectiveApy > highestApy ? effectiveApy.toDouble() : highestApy;
  }

  final blendedApy = totalAmount == 0 ? 0.0 : (estimatedAnnualCarry / totalAmount) * 100;

  return _PortfolioSummary(
    totalAmount: totalAmount,
    estimatedAnnualCarry: estimatedAnnualCarry,
    blendedApy: blendedApy,
    highestApy: highestApy,
  );
}

YieldPool? _findMatchingPool(
  PortfolioPosition position,
  List<YieldPool> pools,
) {
  for (final pool in pools) {
    if (pool.symbol.toUpperCase() == position.symbol.toUpperCase() &&
        pool.chain == position.chain &&
        pool.project == position.platform) {
      return pool;
    }
  }

  for (final pool in pools) {
    if (pool.symbol.toUpperCase() == position.symbol.toUpperCase()) {
      return pool;
    }
  }

  return null;
}
