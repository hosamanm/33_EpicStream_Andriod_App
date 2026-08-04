enum AdminEnvironment { dev, prod }

class AdminConfig {
  final String apiBaseUrl;
  final String appName;
  final AdminEnvironment environment;

  AdminConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.environment,
  });

  static late AdminConfig _instance;
  static AdminConfig get instance => _instance;

  static void init({
    required String apiBaseUrl,
    required String appName,
    required AdminEnvironment environment,
  }) {
    _instance = AdminConfig(
      apiBaseUrl: apiBaseUrl,
      appName: appName,
      environment: environment,
    );
  }
}
