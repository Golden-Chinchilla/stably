class StablecoinChain {
  const StablecoinChain({
    required this.stablecoinId,
    required this.stablecoinSymbol,
    required this.chain,
    required this.current,
    required this.circulatingPrevDay,
    required this.circulatingPrevWeek,
    required this.circulatingPrevMonth,
    required this.updatedAt,
  });

  final String stablecoinId;
  final String stablecoinSymbol;
  final String chain;
  final Map<String, dynamic> current;
  final Map<String, dynamic> circulatingPrevDay;
  final Map<String, dynamic> circulatingPrevWeek;
  final Map<String, dynamic> circulatingPrevMonth;
  final String updatedAt;

  double? get currentPeggedUsd => (current['peggedUSD'] as num?)?.toDouble();

  factory StablecoinChain.fromJson(Map<String, dynamic> json) {
    return StablecoinChain(
      stablecoinId: json['stablecoinId'] as String,
      stablecoinSymbol: json['stablecoinSymbol'] as String,
      chain: json['chain'] as String,
      current: Map<String, dynamic>.from(json['current'] as Map? ?? const {}),
      circulatingPrevDay: Map<String, dynamic>.from(json['circulatingPrevDay'] as Map? ?? const {}),
      circulatingPrevWeek: Map<String, dynamic>.from(json['circulatingPrevWeek'] as Map? ?? const {}),
      circulatingPrevMonth: Map<String, dynamic>.from(json['circulatingPrevMonth'] as Map? ?? const {}),
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
