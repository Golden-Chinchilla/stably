import 'dart:convert';

class PortfolioPosition {
  const PortfolioPosition({
    required this.id,
    required this.platform,
    required this.symbol,
    required this.chain,
    required this.amount,
    required this.apy,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String platform;
  final String symbol;
  final String chain;
  final double amount;
  final double apy;
  final String createdAt;
  final String? note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'platform': platform,
        'symbol': symbol,
        'chain': chain,
        'amount': amount,
        'apy': apy,
        'createdAt': createdAt,
        'note': note,
      };

  factory PortfolioPosition.fromJson(Map<String, dynamic> json) {
    return PortfolioPosition(
      id: json['id'] as String,
      platform: json['platform'] as String,
      symbol: json['symbol'] as String,
      chain: json['chain'] as String,
      amount: (json['amount'] as num).toDouble(),
      apy: (json['apy'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      note: json['note'] as String?,
    );
  }

  static List<PortfolioPosition> decodeList(String raw) {
    final jsonList = jsonDecode(raw) as List<dynamic>;
    return jsonList
        .map((item) => PortfolioPosition.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static String encodeList(List<PortfolioPosition> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }
}
