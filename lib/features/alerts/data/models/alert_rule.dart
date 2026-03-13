import 'dart:convert';

enum AlertRuleType { yieldBelow, newPromoWatch }

class AlertRule {
  const AlertRule({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.frequency,
    required this.enabled,
    this.symbol,
    this.chain,
    this.threshold,
  });

  final String id;
  final AlertRuleType type;
  final String title;
  final String description;
  final String frequency;
  final bool enabled;
  final String? symbol;
  final String? chain;
  final double? threshold;

  AlertRule copyWith({
    String? id,
    AlertRuleType? type,
    String? title,
    String? description,
    String? frequency,
    bool? enabled,
    String? symbol,
    String? chain,
    double? threshold,
    bool clearSymbol = false,
    bool clearChain = false,
    bool clearThreshold = false,
  }) {
    return AlertRule(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      enabled: enabled ?? this.enabled,
      symbol: clearSymbol ? null : (symbol ?? this.symbol),
      chain: clearChain ? null : (chain ?? this.chain),
      threshold: clearThreshold ? null : (threshold ?? this.threshold),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'frequency': frequency,
    'enabled': enabled,
    'symbol': symbol,
    'chain': chain,
    'threshold': threshold,
  };

  factory AlertRule.fromJson(Map<String, dynamic> json) {
    return AlertRule(
      id: json['id'] as String,
      type: AlertRuleType.values.firstWhere(
        (item) => item.name == json['type'],
        orElse: () => AlertRuleType.yieldBelow,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      frequency: json['frequency'] as String,
      enabled: json['enabled'] as bool? ?? true,
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      threshold: (json['threshold'] as num?)?.toDouble(),
    );
  }

  static String encodeList(List<AlertRule> rules) {
    return jsonEncode(rules.map((rule) => rule.toJson()).toList());
  }

  static List<AlertRule> decodeList(String raw) {
    final jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map(
          (item) => AlertRule.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
