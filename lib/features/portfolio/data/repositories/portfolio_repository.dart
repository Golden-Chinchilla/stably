import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    await preferences.setString(
      _positionsStorageKey,
      PortfolioPosition.encodeList(positions),
    );
  }

  Future<List<PortfolioPosition>> addPosition(
    PortfolioPosition position,
  ) async {
    final current = await loadPositions();
    final updated = [...current, position];
    await savePositions(updated);
    return updated;
  }

  Future<List<PortfolioPosition>> updatePosition(
    PortfolioPosition position,
  ) async {
    final current = await loadPositions();
    final updated = [
      for (final item in current)
        if (item.id == position.id) position else item,
    ];
    await savePositions(updated);
    return updated;
  }

  Future<List<PortfolioPosition>> deletePosition(String id) async {
    final current = await loadPositions();
    final updated = current.where((item) => item.id != id).toList();
    await savePositions(updated);
    return updated;
  }

  Future<void> clearPositions() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_positionsStorageKey);
  }
}

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return const PortfolioRepository();
});
