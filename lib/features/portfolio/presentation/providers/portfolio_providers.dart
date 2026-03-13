import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Future<void> clearAll() async {
    state = const AsyncLoading();
    await _repository.clearPositions();
    state = const AsyncData([]);
  }

  Future<void> addPosition(PortfolioPosition position) async {
    final previous = state.maybeWhen(
      data: (positions) => positions,
      orElse: () => <PortfolioPosition>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.addPosition(position));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }

  Future<void> updatePosition(PortfolioPosition position) async {
    final previous = state.maybeWhen(
      data: (positions) => positions,
      orElse: () => <PortfolioPosition>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.updatePosition(position));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }

  Future<void> deletePosition(String id) async {
    final previous = state.maybeWhen(
      data: (positions) => positions,
      orElse: () => <PortfolioPosition>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.deletePosition(id));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }
}
