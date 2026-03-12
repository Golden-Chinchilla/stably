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
}
