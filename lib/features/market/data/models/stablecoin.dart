class Stablecoin {
  const Stablecoin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.geckoId,
    required this.price,
    required this.chains,
    required this.circulating,
    required this.circulatingPrevDay,
    required this.circulatingPrevWeek,
    required this.circulatingPrevMonth,
    required this.chainCirculating,
    required this.pegMechanism,
    required this.priceSource,
    required this.pegType,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String symbol;
  final String? geckoId;
  final double? price;
  final List<String> chains;
  final Map<String, dynamic> circulating;
  final Map<String, dynamic> circulatingPrevDay;
  final Map<String, dynamic> circulatingPrevWeek;
  final Map<String, dynamic> circulatingPrevMonth;
  final Map<String, dynamic> chainCirculating;
  final String? pegMechanism;
  final String? priceSource;
  final String? pegType;
  final String updatedAt;

  double? get circulatingPeggedUsd =>
      (circulating['peggedUSD'] as num?)?.toDouble();

  factory Stablecoin.fromJson(Map<String, dynamic> json) {
    return Stablecoin(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      geckoId: json['geckoId'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      chains: (json['chains'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      circulating: Map<String, dynamic>.from(
        json['circulating'] as Map? ?? const {},
      ),
      circulatingPrevDay: Map<String, dynamic>.from(
        json['circulatingPrevDay'] as Map? ?? const {},
      ),
      circulatingPrevWeek: Map<String, dynamic>.from(
        json['circulatingPrevWeek'] as Map? ?? const {},
      ),
      circulatingPrevMonth: Map<String, dynamic>.from(
        json['circulatingPrevMonth'] as Map? ?? const {},
      ),
      chainCirculating: Map<String, dynamic>.from(
        json['chainCirculating'] as Map? ?? const {},
      ),
      pegMechanism: json['pegMechanism'] as String?,
      priceSource: json['priceSource'] as String?,
      pegType: json['pegType'] as String?,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
