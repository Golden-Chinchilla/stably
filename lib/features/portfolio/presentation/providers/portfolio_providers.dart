import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';
import 'package:stably_app/features/portfolio/data/models/portfolio_position.dart';
import 'package:stably_app/features/portfolio/data/repositories/portfolio_repository.dart';

final portfolioControllerProvider =
    AsyncNotifierProvider<PortfolioController, List<PortfolioPosition>>(
  PortfolioController.new,
);

class PortfolioController extends AsyncNotifier<List<PortfolioPosition>> {
  PortfolioRepository get _repository => ref.read(portfolioRepositoryProvider);

  @override
  Future<List<PortfolioPosition>> build() async {
    return _repository.loadPositions();
  }

  Future<void> seedDemoFromLivePools() async {
    state = const AsyncLoading();
    final pools = await ref.read(yieldPoolsProvider.future);
    final seeded = await _repository.seedFromPools(pools);
    state = AsyncData(seeded);
  }

  Future<void> clearAll() async {
    state = const AsyncLoading();
    await _repository.clearPositions();
    state = const AsyncData([]);
  }
}
