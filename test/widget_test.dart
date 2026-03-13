import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stably_app/features/market/data/models/health_status.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/stablecoin_chain.dart';
import 'package:stably_app/features/market/data/models/stablecoin_detail.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/data/repositories/market_repository.dart';
import 'package:stably_app/main.dart';
import 'package:stably_app/shared/network/api_client.dart';

void main() {
  testWidgets('renders shell navigation and home content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketRepositoryProvider.overrideWith(
            (ref) => _FakeMarketRepository(),
          ),
        ],
        child: const StablyBootstrap(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.home), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.compass_fill), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.chart_bar_alt_fill), findsOneWidget);
    expect(
      find.byIcon(CupertinoIcons.money_dollar_circle_fill),
      findsOneWidget,
    );
    expect(find.byIcon(CupertinoIcons.bell_fill), findsOneWidget);
    expect(find.text('Market Overview'), findsOneWidget);
    expect(find.textContaining('USDC'), findsWidgets);
  });
}

class _FakeMarketRepository extends MarketRepository {
  _FakeMarketRepository() : super(ApiClient(Dio()));

  static const _updatedAt = '2026-03-12T10:15:51.062Z';

  final List<Stablecoin> _stablecoins = [
    Stablecoin.fromJson({
      'id': 'usdc',
      'name': 'USD Coin',
      'symbol': 'USDC',
      'geckoId': 'usd-coin',
      'price': 1.0,
      'chains': ['Ethereum', 'Base', 'Arbitrum'],
      'circulating': {'peggedUSD': 56000000000},
      'circulatingPrevDay': {'peggedUSD': 55900000000},
      'circulatingPrevWeek': {'peggedUSD': 55300000000},
      'circulatingPrevMonth': {'peggedUSD': 54800000000},
      'chainCirculating': {
        'Ethereum': {
          'current': {'peggedUSD': 24000000000},
        },
        'Base': {
          'current': {'peggedUSD': 18000000000},
        },
        'Arbitrum': {
          'current': {'peggedUSD': 14000000000},
        },
      },
      'pegMechanism': 'fiat-backed',
      'priceSource': 'defillama',
      'pegType': 'peggedUSD',
      'updatedAt': _updatedAt,
    }),
    Stablecoin.fromJson({
      'id': 'usdt',
      'name': 'Tether',
      'symbol': 'USDT',
      'geckoId': 'tether',
      'price': 1.0,
      'chains': ['Tron', 'Ethereum'],
      'circulating': {'peggedUSD': 183000000000},
      'circulatingPrevDay': {'peggedUSD': 182500000000},
      'circulatingPrevWeek': {'peggedUSD': 182000000000},
      'circulatingPrevMonth': {'peggedUSD': 181000000000},
      'chainCirculating': {
        'Tron': {
          'current': {'peggedUSD': 85000000000},
        },
        'Ethereum': {
          'current': {'peggedUSD': 78000000000},
        },
      },
      'pegMechanism': 'fiat-backed',
      'priceSource': 'defillama',
      'pegType': 'peggedUSD',
      'updatedAt': _updatedAt,
    }),
  ];

  final List<YieldPool> _pools = [
    YieldPool.fromJson({
      'pool': 'pool-usdc-1',
      'project': 'yearn-finance',
      'chain': 'Ethereum',
      'symbol': 'USDC',
      'apy': 12.4,
      'tvlUsd': 520000,
      'poolMeta': null,
      'updatedAt': _updatedAt,
    }),
    YieldPool.fromJson({
      'pool': 'pool-usdc-2',
      'project': 'aave-v3',
      'chain': 'Base',
      'symbol': 'USDC',
      'apy': 8.2,
      'tvlUsd': 2400000,
      'poolMeta': 'Lending',
      'updatedAt': _updatedAt,
    }),
    YieldPool.fromJson({
      'pool': 'pool-usdt-1',
      'project': 'aave-v3',
      'chain': 'Ethereum',
      'symbol': 'USDT',
      'apy': 6.7,
      'tvlUsd': 1900000,
      'poolMeta': 'Lending',
      'updatedAt': _updatedAt,
    }),
  ];

  @override
  Future<HealthStatus> fetchHealth() async {
    return const HealthStatus(
      stablecoinsSyncedAt: _updatedAt,
      poolsSyncedAt: _updatedAt,
      cefiSyncedAt: _updatedAt,
    );
  }

  @override
  Future<List<Stablecoin>> fetchStablecoins({
    int limit = 20,
    String? symbol,
    String? pegType,
  }) async {
    var items = _stablecoins;

    if (symbol != null) {
      items = items.where((item) => item.symbol == symbol).toList();
    }
    if (pegType != null) {
      items = items.where((item) => item.pegType == pegType).toList();
    }

    return items.take(limit).toList();
  }

  @override
  Future<StablecoinDetail> fetchStablecoinDetail(String stablecoinId) async {
    final stablecoin = _stablecoins.firstWhere(
      (item) => item.id == stablecoinId,
    );
    final chainData = <StablecoinChain>[
      if (stablecoin.symbol == 'USDC') ...[
        StablecoinChain.fromJson({
          'stablecoinId': stablecoin.id,
          'stablecoinSymbol': stablecoin.symbol,
          'chain': 'Ethereum',
          'current': {'peggedUSD': 24000000000},
          'circulatingPrevDay': {'peggedUSD': 23900000000},
          'circulatingPrevWeek': {'peggedUSD': 23600000000},
          'circulatingPrevMonth': {'peggedUSD': 23300000000},
          'updatedAt': _updatedAt,
        }),
        StablecoinChain.fromJson({
          'stablecoinId': stablecoin.id,
          'stablecoinSymbol': stablecoin.symbol,
          'chain': 'Base',
          'current': {'peggedUSD': 18000000000},
          'circulatingPrevDay': {'peggedUSD': 17950000000},
          'circulatingPrevWeek': {'peggedUSD': 17600000000},
          'circulatingPrevMonth': {'peggedUSD': 17200000000},
          'updatedAt': _updatedAt,
        }),
      ],
    ];

    return StablecoinDetail(stablecoin: stablecoin, chainData: chainData);
  }

  @override
  Future<List<StablecoinChain>> fetchStablecoinChains({
    int limit = 20,
    String? stablecoinId,
    String? symbol,
    String? chain,
  }) async {
    final detail = await fetchStablecoinDetail(stablecoinId ?? 'usdc');
    var items = detail.chainData;

    if (symbol != null) {
      items = items.where((item) => item.stablecoinSymbol == symbol).toList();
    }
    if (chain != null) {
      items = items.where((item) => item.chain == chain).toList();
    }

    return items.take(limit).toList();
  }

  @override
  Future<List<YieldPool>> fetchYieldPools({
    int limit = 20,
    String? symbol,
    String? chain,
    String? project,
  }) async {
    var items = _pools;

    if (symbol != null) {
      items = items.where((item) => item.symbol == symbol).toList();
    }
    if (chain != null) {
      items = items.where((item) => item.chain == chain).toList();
    }
    if (project != null) {
      items = items.where((item) => item.project == project).toList();
    }

    return items.take(limit).toList();
  }
}
