import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stably_app/features/alerts/data/models/alert_rule.dart';
import 'package:stably_app/features/alerts/data/repositories/alert_rule_repository.dart';
import 'package:stably_app/features/market/presentation/providers/market_providers.dart';

final alertRulesControllerProvider =
    AsyncNotifierProvider<AlertRulesController, List<AlertRule>>(
      AlertRulesController.new,
    );

class AlertRulesController extends AsyncNotifier<List<AlertRule>> {
  AlertRuleRepository get _repository => ref.read(alertRuleRepositoryProvider);

  @override
  Future<List<AlertRule>> build() async {
    return _repository.loadRules();
  }

  Future<void> seedDemoRules() async {
    state = const AsyncLoading();
    final pools = await ref.read(yieldPoolsProvider.future);
    final rules = await _repository.seedDemoRules(pools);
    state = AsyncData(rules);
  }

  Future<void> clearRules() async {
    state = const AsyncLoading();
    await _repository.clearRules();
    state = const AsyncData([]);
  }

  Future<void> addRule(AlertRule rule) async {
    final previous = state.maybeWhen(
      data: (rules) => rules,
      orElse: () => <AlertRule>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.addRule(rule));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }

  Future<void> updateRule(AlertRule rule) async {
    final previous = state.maybeWhen(
      data: (rules) => rules,
      orElse: () => <AlertRule>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.updateRule(rule));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }

  Future<void> deleteRule(String id) async {
    final previous = state.maybeWhen(
      data: (rules) => rules,
      orElse: () => <AlertRule>[],
    );
    state = const AsyncLoading();
    try {
      state = AsyncData(await _repository.deleteRule(id));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      state = AsyncData(previous);
    }
  }
}
