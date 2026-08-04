enum Environment { dev, prod }

class AppConfig {
  final String apiBaseUrl;
  final String appName;
  final Environment environment;

  AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.environment,
  });

  static late AppConfig _instance;
  static AppConfig get instance => _instance;

  static void init({
    required String apiBaseUrl,
    required String appName,
    required Environment environment,
  }) {
    _instance = AppConfig(
      apiBaseUrl: apiBaseUrl,
      appName: appName,
      environment: environment,
    );
  }
}
