import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';
import 'package:stably_app/features/portfolio/data/models/portfolio_position.dart';

const _positionsStorageKey = 'portfolio_positions_v1';

class PortfolioRepository {
  const PortfolioRepository();

  Future<List<PortfolioPosition>> loadPositions() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_positionsStorageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    return PortfolioPosition.decodeList(raw);
  }

  Future<void> savePositions(List<PortfolioPosition> positions) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_positionsStorageKey, PortfolioPosition.encodeList(positions));
  }

  Future<void> clearPositions() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_positionsStorageKey);
  }

  Future<List<PortfolioPosition>> seedFromPools(List<YieldPool> pools) async {
    final now = DateTime.now().toIso8601String();
    final selected = pools.take(3).toList();
    final seeded = <PortfolioPosition>[
      for (var index = 0; index < selected.length; index++)
        PortfolioPosition(
          id: '${selected[index].pool}-$index',
          platform: selected[index].project,
          symbol: selected[index].symbol,
          chain: selected[index].chain,
          amount: switch (index) {
            0 => 5000,
            1 => 3000,
            _ => 2000,
          }.toDouble(),
          apy: selected[index].apy ?? 0,
          createdAt: now,
          note: index == 0 ? 'Seeded from live pool board' : null,
        ),
    ];

    await savePositions(seeded);
    return seeded;
  }
}

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return const PortfolioRepository();
});
