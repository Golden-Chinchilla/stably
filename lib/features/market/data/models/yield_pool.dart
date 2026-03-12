class YieldPool {
  const YieldPool({
    required this.pool,
    required this.project,
    required this.chain,
    required this.symbol,
    required this.apy,
    required this.tvlUsd,
    required this.poolMeta,
    required this.updatedAt,
  });

  final String pool;
  final String project;
  final String chain;
  final String symbol;
  final double? apy;
  final double? tvlUsd;
  final String? poolMeta;
  final String updatedAt;

  factory YieldPool.fromJson(Map<String, dynamic> json) {
    return YieldPool(
      pool: json['pool'] as String,
      project: json['project'] as String,
      chain: json['chain'] as String,
      symbol: json['symbol'] as String,
      apy: (json['apy'] as num?)?.toDouble(),
      tvlUsd: (json['tvlUsd'] as num?)?.toDouble(),
      poolMeta: json['poolMeta'] as String?,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}
