class HealthStatus {
  const HealthStatus({
    required this.stablecoinsSyncedAt,
    required this.poolsSyncedAt,
  });

  final String? stablecoinsSyncedAt;
  final String? poolsSyncedAt;

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    final syncState = json['syncState'] as Map<String, dynamic>? ?? const {};
    return HealthStatus(
      stablecoinsSyncedAt: syncState['stablecoins'] as String?,
      poolsSyncedAt: syncState['pools'] as String?,
    );
  }
}
