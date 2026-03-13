class CefiProduct {
  const CefiProduct({
    required this.id,
    required this.exchange,
    required this.assetSymbol,
    required this.apr,
    required this.productType,
    required this.termDays,
    required this.status,
  });

  final String id;
  final String exchange;
  final String assetSymbol;
  final double? apr;
  final String productType;
  final int? termDays;
  final String status;

  factory CefiProduct.fromJson(Map<String, dynamic> json) {
    return CefiProduct(
      id: json['id'] as String,
      exchange: json['exchange'] as String,
      assetSymbol: json['assetSymbol'] as String,
      apr: (json['apr'] as num?)?.toDouble(),
      productType: json['productType'] as String? ?? 'flexible',
      termDays: (json['termDays'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'unknown',
    );
  }
}
