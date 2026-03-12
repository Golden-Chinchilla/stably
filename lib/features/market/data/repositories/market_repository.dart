import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/data/models/health_status.dart';
import 'package:stably_app/features/market/data/models/stablecoin.dart';
import 'package:stably_app/features/market/data/models/stablecoin_chain.dart';
import 'package:stably_app/features/market/data/models/stablecoin_detail.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/shared/network/api_client.dart';

class MarketRepository {
  const MarketRepository(this._client);

  final ApiClient _client;

  Future<HealthStatus> fetchHealth() async {
    final body = await _client.getJson('/api/health');
    return HealthStatus.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<List<Stablecoin>> fetchStablecoins({
    int limit = 20,
    String? symbol,
    String? pegType,
  }) async {
    final queryParameters = {
      'limit': limit,
      'symbol': symbol,
      'pegType': pegType,
    }..removeWhere((key, value) => value == null);

    final body = await _client.getJson(
      '/api/stablecoins',
      queryParameters: queryParameters,
    );

    return (body['data'] as List? ?? const [])
        .map((item) => Stablecoin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<StablecoinDetail> fetchStablecoinDetail(String stablecoinId) async {
    final body = await _client.getJson('/api/stablecoins/$stablecoinId');
    return StablecoinDetail.fromJson(Map<String, dynamic>.from(body['data'] as Map));
  }

  Future<List<StablecoinChain>> fetchStablecoinChains({
    int limit = 20,
    String? stablecoinId,
    String? symbol,
    String? chain,
  }) async {
    final queryParameters = {
      'limit': limit,
      'stablecoinId': stablecoinId,
      'symbol': symbol,
      'chain': chain,
    }..removeWhere((key, value) => value == null);

    final body = await _client.getJson(
      '/api/stablecoin-chains',
      queryParameters: queryParameters,
    );

    return (body['data'] as List? ?? const [])
        .map((item) => StablecoinChain.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<List<YieldPool>> fetchYieldPools({
    int limit = 20,
    String? symbol,
    String? chain,
    String? project,
  }) async {
    final queryParameters = {
      'limit': limit,
      'symbol': symbol,
      'chain': chain,
      'project': project,
    }..removeWhere((key, value) => value == null);

    final body = await _client.getJson(
      '/api/pools',
      queryParameters: queryParameters,
    );

    return (body['data'] as List? ?? const [])
        .map((item) => YieldPool.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return MarketRepository(client);
});
