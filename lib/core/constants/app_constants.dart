class AppConstants {
  AppConstants._();

  static const String appName = 'EpicStream';
  
  // API Endpoints
  static const String moviesEndpoint = '/movies';
  static const String seriesEndpoint = '/series';
  static const String authEndpoint = '/auth';

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String themeKey = 'is_dark_mode';

  // Design Constants
  static const double defaultPadding = 16.0;
  static const double borderRadius = 8.0;
}
