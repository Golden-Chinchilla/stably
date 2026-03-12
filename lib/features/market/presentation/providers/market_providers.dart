import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/health_status.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/stablecoin_chain.dart';
import 'package:stably_app/features/market/data/models/stablecoin_detail.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/market/data/repositories/market_repository.dart';

final healthProvider = FutureProvider<HealthStatus>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.fetchHealth();
});

final stablecoinsProvider = FutureProvider<List<Stablecoin>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.fetchStablecoins(limit: 12);
});

final stablecoinDetailProvider =
    FutureProvider.family<StablecoinDetail, String>((ref, stablecoinId) async {
      final repository = ref.watch(marketRepositoryProvider);
      return repository.fetchStablecoinDetail(stablecoinId);
    });

final stablecoinChainsProvider = FutureProvider<List<StablecoinChain>>((
  ref,
) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.fetchStablecoinChains(limit: 12);
});

final yieldPoolsProvider = FutureProvider<List<YieldPool>>((ref) async {
  final repository = ref.watch(marketRepositoryProvider);
  return repository.fetchYieldPools(limit: 12);
});

final yieldPoolsBySymbolProvider =
    FutureProvider.family<List<YieldPool>, String>((ref, symbol) async {
      final repository = ref.watch(marketRepositoryProvider);
      return repository.fetchYieldPools(limit: 20, symbol: symbol);
    });

final yieldPoolsBySymbolAndChainProvider =
    FutureProvider.family<List<YieldPool>, ({String symbol, String? chain})>((
      ref,
      filter,
    ) async {
      final repository = ref.watch(marketRepositoryProvider);
      return repository.fetchYieldPools(
        limit: 20,
        symbol: filter.symbol,
        chain: filter.chain,
      );
    });
