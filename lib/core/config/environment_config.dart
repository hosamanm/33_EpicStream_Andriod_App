enum AppEnvironment { development, staging, production }

class EnvironmentConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final String firebaseAppCheckKey;
  final bool enableSecureLogging;

  EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseAppCheckKey,
    this.enableSecureLogging = false,
  });

  static late EnvironmentConfig _instance;
  static EnvironmentConfig get instance => _instance;

  static void init({
    required AppEnvironment environment,
    required String apiBaseUrl,
    required String firebaseAppCheckKey,
  }) {
    _instance = EnvironmentConfig(
      environment: environment,
      apiBaseUrl: apiBaseUrl,
      firebaseAppCheckKey: firebaseAppCheckKey,
      enableSecureLogging: environment != AppEnvironment.production,
    );
  }

  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;
}
