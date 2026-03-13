import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stably_app/features/alerts/data/models/alert_rule.dart';

const _alertRulesStorageKey = 'alert_rules_v1';

class AlertRuleRepository {
  const AlertRuleRepository();

  Future<List<AlertRule>> loadRules() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_alertRulesStorageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    return AlertRule.decodeList(raw);
  }

  Future<void> saveRules(List<AlertRule> rules) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _alertRulesStorageKey,
      AlertRule.encodeList(rules),
    );
  }

  Future<List<AlertRule>> addRule(AlertRule rule) async {
    final current = await loadRules();
    final updated = [...current, rule];
    await saveRules(updated);
    return updated;
  }

  Future<List<AlertRule>> updateRule(AlertRule rule) async {
    final current = await loadRules();
    final updated = [
      for (final item in current)
        if (item.id == rule.id) rule else item,
    ];
    await saveRules(updated);
    return updated;
  }

  Future<List<AlertRule>> deleteRule(String id) async {
    final current = await loadRules();
    final updated = current.where((item) => item.id != id).toList();
    await saveRules(updated);
    return updated;
  }

  Future<void> clearRules() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_alertRulesStorageKey);
  }
}

final alertRuleRepositoryProvider = Provider<AlertRuleRepository>((ref) {
  return const AlertRuleRepository();
});
