class AppEnvironment {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://stably-worker.gaojieli2020.workers.dev',
  );
}
