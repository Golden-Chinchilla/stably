import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stably_app/app/l10n/app_localizations.dart';
import 'package:stably_app/app/router/app_router.dart';
import 'package:stably_app/features/market/data/models/cefi_product.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/shared/utils/formatters.dart';
import 'package:stably_app/shared/widgets/app_empty_state.dart';
import 'package:stably_app/shared/widgets/app_filter_chip.dart';
import 'package:stably_app/shared/widgets/app_page_scaffold.dart';
import 'package:stably_app/shared/widgets/app_search_field.dart';
import 'package:stably_app/shared/widgets/app_skeleton.dart';
import 'package:stably_app/shared/widgets/async_section_state.dart';
import 'package:stably_app/shared/widgets/base_card.dart';
import 'package:stably_app/shared/widgets/highlight_panel.dart';
import 'package:stably_app/shared/widgets/insight_tile.dart';
import 'package:stably_app/shared/widgets/opportunity_card.dart';
import 'package:stably_app/shared/widgets/pill_button.dart';
import 'package:stably_app/shared/widgets/risk_notice_card.dart';
import 'package:stably_app/shared/widgets/section_block.dart';
import 'package:stably_app/shared/widgets/status_tag.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.refresh(yieldPoolsProvider.future),
      ref.refresh(stablecoinsProvider.future),
      ref.refresh(cefiProductsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final poolsAsync = ref.watch(yieldPoolsProvider);
    final stablecoinsAsync = ref.watch(stablecoinsProvider);
    final cefiAsync = ref.watch(cefiProductsProvider);

    return AppPageScaffold(
      title: context.tr('Yield Discovery'),
      onRefresh: _refresh,
      children: [
        SectionBlock(
          title: context.tr('Discovery Overview'),
          child: poolsAsync.when(
            data: (pools) {
              final sortedPools = _sortYieldPools(pools);
              final topPool = sortedPools.isNotEmpty ? sortedPools.first : null;

              return HighlightPanel(
                title: topPool == null
                    ? 'Top 20 stablecoin pool coverage is online.'
                    : '${topPool.project} leads the current top 20 stablecoin pool board.',
                value: topPool == null ? '—' : formatPercent(topPool.apy),
                secondaryValue: '${pools.length} pools',
                tag: 'Top 20',
              );
            },
            loading: () => const AppHighlightPanelSkeleton(),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: _refresh,
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Search'),
          child: AppSearchField(
            controller: _searchController,
            placeholder: 'Search top 20 stablecoins, pools, CeFi, or chains',
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
        ),
        SectionBlock(
          title: context.tr('Top 20 Stablecoins'),
          child: stablecoinsAsync.when(
            data: (stablecoins) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final stablecoin in _sortStablecoins(
                  _filterStablecoins(stablecoins),
                ).take(5))
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
              onRetry: _refresh,
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Stablecoin Coverage'),
          child: stablecoinsAsync.when(
            data: (stablecoins) => _StablecoinBoard(
              stablecoins: _sortStablecoins(
                _filterStablecoins(stablecoins),
              ).take(4).toList(),
            ),
            loading: () => const AppListSkeleton(items: 4),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: _refresh,
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Yield Pool Board'),
          child: poolsAsync.when(
            data: (pools) {
              final filteredPools = _sortYieldPools(_filterPools(pools));

              if (filteredPools.isEmpty) {
                return const AppEmptyState(
                  title: 'No yield pools yet',
                  description:
                      'No top-20 stablecoin pools match the current search or market set.',
                  icon: CupertinoIcons.search_circle,
                );
              }

              final topPool = filteredPools.first;
              final baselinePool = filteredPools.firstWhere(
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
                          caption:
                              '${baselinePool.project} · ${baselinePool.chain}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DiscoverPoolList(pools: filteredPools.take(3).toList()),
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
              onRetry: _refresh,
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('CeFi Board'),
          child: cefiAsync.when(
            data: (products) {
              final filteredProducts =
                  _sortCefiProducts(_filterCefiProducts(products));

              if (filteredProducts.isEmpty) {
                return const AppEmptyState(
                  title: 'No CeFi products yet',
                  description:
                      'No Binance or OKX offers match the current search or sync state.',
                  icon: CupertinoIcons.building_2_fill,
                );
              }

              final topProduct = filteredProducts.first;
              final flexibleCount = filteredProducts
                  .where((item) => item.productType == 'flexible')
                  .length;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.building_2_fill,
                          label: 'Top CeFi APY',
                          value: formatPercent(topProduct.apr),
                          caption:
                              '${_displayExchange(topProduct.exchange)} · ${topProduct.assetSymbol}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InsightTile(
                          icon: CupertinoIcons.clock_fill,
                          label: 'Flexible offers',
                          value: '$flexibleCount',
                          caption: '${filteredProducts.length} offers from Binance and OKX',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DiscoverCefiList(
                    products: filteredProducts.take(3).toList(),
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
                AppListSkeleton(items: 3),
              ],
            ),
            error: (error, _) => AsyncSectionState.error(
              message: AsyncSectionState.presentError(error),
              onRetry: _refresh,
            ),
          ),
        ),
        SectionBlock(
          title: context.tr('Research Notes'),
          child: Column(
            children: [
              RiskNoticeCard(
                title: 'CeFi is limited to Binance and OKX',
                description:
                    'The CeFi board currently tracks six core fields from Binance and OKX only.',
                tone: StatusTagTone.info,
              ),
              SizedBox(height: 12),
              RiskNoticeCard(
                title: 'DeFi is filtered to the top 20 stablecoins',
                description:
                    'DefiLlama pools outside the current top 20 stablecoin set are intentionally excluded from discovery.',
                tone: StatusTagTone.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Stablecoin> _filterStablecoins(List<Stablecoin> stablecoins) {
    if (_query.isEmpty) {
      return stablecoins;
    }
    return stablecoins.where((stablecoin) {
      final haystack = [
        stablecoin.symbol,
        stablecoin.name,
        ...stablecoin.chains,
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  List<YieldPool> _filterPools(List<YieldPool> pools) {
    if (_query.isEmpty) {
      return pools;
    }
    return pools.where((pool) {
      final haystack = [
        pool.project,
        pool.symbol,
        pool.chain,
        pool.poolMeta ?? '',
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }

  List<CefiProduct> _filterCefiProducts(List<CefiProduct> products) {
    if (_query.isEmpty) {
      return products;
    }
    return products.where((product) {
      final haystack = [
        product.exchange,
        product.assetSymbol,
        product.productType,
        product.status,
      ].join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
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
        description:
            'Run a backend sync to populate the current top 20 stablecoin board.',
        icon: CupertinoIcons.money_dollar_circle,
      );
    }

    final cards = <Widget>[
      for (var index = 0; index < stablecoins.length; index++) ...[
        _StablecoinBoardCard(stablecoin: stablecoins[index]),
        if (index != stablecoins.length - 1) const SizedBox(height: 12),
      ],
    ];

    return Column(
      children: cards
          .animate(interval: 50.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _StablecoinBoardCard extends StatelessWidget {
  const _StablecoinBoardCard({required this.stablecoin});

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
            ],
          ),
        ],
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
        .maybeWhen(data: (items) => items, orElse: () => const <Stablecoin>[]);

    for (final stablecoin in inherited) {
      stablecoins[stablecoin.symbol] = stablecoin;
    }

    final cards = <Widget>[
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
          onTap: () {
            final stablecoin =
                stablecoins[pools[index].symbol.toUpperCase()] ??
                stablecoins[pools[index].symbol];
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
    ];

    return Column(
      children: cards
          .animate(interval: 50.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}

class _DiscoverCefiList extends StatelessWidget {
  const _DiscoverCefiList({required this.products});

  final List<CefiProduct> products;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      for (var index = 0; index < products.length; index++) ...[
        OpportunityCard(
          icon: products[index].productType == 'fixed'
              ? CupertinoIcons.lock_fill
              : CupertinoIcons.building_2_fill,
          platform: _displayExchange(products[index].exchange),
          asset: products[index].assetSymbol,
          apy: formatPercent(products[index].apr),
          summary:
              '${_displayProductType(products[index].productType)} · ${_displayStatus(products[index].status)}',
          tags: [
            _displayProductType(products[index].productType),
            _displayTerm(products[index].termDays),
            _displayStatus(products[index].status),
          ],
          tone: (products[index].apr ?? 0) >= 10
              ? StatusTagTone.success
              : StatusTagTone.info,
        ),
        if (index != products.length - 1) const SizedBox(height: 16),
      ],
    ];

    return Column(
      children: cards
          .animate(interval: 50.ms)
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  }
}

String _displayExchange(String value) {
  return switch (value.toLowerCase()) {
    'binance' => 'Binance',
    'okx' => 'OKX',
    _ => value,
  };
}

String _displayProductType(String value) {
  return switch (value.toLowerCase()) {
    'fixed' => 'Fixed',
    _ => 'Flexible',
  };
}

String _displayStatus(String value) {
  return switch (value.toLowerCase()) {
    'available' => 'Available',
    'sold_out' => 'Sold out',
    'ended' => 'Ended',
    _ => 'Unknown',
  };
}

String _displayTerm(int? termDays) {
  if (termDays == null || termDays == 0) {
    return 'Flexible';
  }

  return '$termDays d';
}

List<Stablecoin> _sortStablecoins(List<Stablecoin> stablecoins) {
  final sorted = [...stablecoins];
  sorted.sort(
    (left, right) => (right.circulatingPeggedUsd ?? 0)
        .compareTo(left.circulatingPeggedUsd ?? 0),
  );
  return sorted;
}

List<YieldPool> _sortYieldPools(List<YieldPool> pools) {
  final sorted = [...pools];
  sorted.sort((left, right) {
    final apyCompare = (right.apy ?? -1).compareTo(left.apy ?? -1);
    if (apyCompare != 0) {
      return apyCompare;
    }

    return (right.tvlUsd ?? -1).compareTo(left.tvlUsd ?? -1);
  });
  return sorted;
}

List<CefiProduct> _sortCefiProducts(List<CefiProduct> products) {
  final assetPriority = {
    'USDT': 0,
    'USDC': 1,
    'FDUSD': 2,
    'USDE': 3,
  };
  final exchangePriority = {
    'binance': 0,
    'okx': 1,
  };

  final sorted = [...products];
  sorted.sort((left, right) {
    final statusCompare =
        _statusRank(right.status).compareTo(_statusRank(left.status));
    if (statusCompare != 0) {
      return statusCompare;
    }

    final aprCompare = (right.apr ?? -1).compareTo(left.apr ?? -1);
    if (aprCompare != 0) {
      return aprCompare;
    }

    final typeCompare = _productTypeRank(left.productType)
        .compareTo(_productTypeRank(right.productType));
    if (typeCompare != 0) {
      return typeCompare;
    }

    final assetCompare = (assetPriority[left.assetSymbol.toUpperCase()] ?? 99)
        .compareTo(assetPriority[right.assetSymbol.toUpperCase()] ?? 99);
    if (assetCompare != 0) {
      return assetCompare;
    }

    return (exchangePriority[left.exchange.toLowerCase()] ?? 99)
        .compareTo(exchangePriority[right.exchange.toLowerCase()] ?? 99);
  });
  return sorted;
}

int _statusRank(String status) {
  return switch (status.toLowerCase()) {
    'available' => 2,
    'sold_out' => 1,
    'ended' => 0,
    _ => -1,
  };
}

int _productTypeRank(String productType) {
  return switch (productType.toLowerCase()) {
    'flexible' => 0,
    'fixed' => 1,
    _ => 2,
  };
}
