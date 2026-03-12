import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stably_app/features/alerts/data/models/alert_rule.dart';
import 'package:stably_app/features/market/data/models/yield_pool.dart';

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
    await preferences.setString(_alertRulesStorageKey, AlertRule.encodeList(rules));
  }

  Future<void> clearRules() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_alertRulesStorageKey);
  }

  Future<List<AlertRule>> seedDemoRules(List<YieldPool> pools) async {
    final topPool = pools.isNotEmpty ? pools.first : null;
    final rules = <AlertRule>[
      AlertRule(
        id: 'yield-below-usdc',
        type: AlertRuleType.yieldBelow,
        title: 'USDC flexible yield falls below 4%',
        description: 'Notify when baseline yields compress enough to justify a manual review.',
        frequency: 'Enabled',
        enabled: true,
        symbol: 'USDC',
        threshold: 4,
      ),
      AlertRule(
        id: 'promo-watch',
        type: AlertRuleType.newPromoWatch,
        title: 'New exchange promo appears',
        description: 'Surface short-lived campaign changes quickly so capped buckets can be reviewed.',
        frequency: 'Instant',
        enabled: true,
        symbol: topPool?.symbol,
        chain: topPool?.chain,
      ),
      const AlertRule(
        id: 'portfolio-drift',
        type: AlertRuleType.portfolioDrift,
        title: 'Portfolio drifts from suggested split',
        description: 'Remind when tracked positions diverge materially from the sample allocation.',
        frequency: 'Daily',
        enabled: true,
      ),
    ];

    await saveRules(rules);
    return rules;
  }
}

final alertRuleRepositoryProvider = Provider<AlertRuleRepository>((ref) {
  return const AlertRuleRepository();
});
