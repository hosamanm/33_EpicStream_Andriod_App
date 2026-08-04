import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

/// Service to manage Firebase App Check.
/// Protects backend resources from abuse by verifying that requests
/// come from your authentic app on genuine devices.
class AppCheckService {
  
  Future<void> initialize() async {
    // App Check is essential for production OTT platforms to prevent 
    // unauthorized API access and malicious traffic.
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode 
          ? AndroidProvider.debug 
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode 
          ? AppleProvider.debug 
          : AppleProvider.appAttest,
      webProvider: ReCaptchaV3Provider(EnvironmentConfig.instance.firebaseAppCheckKey),
    );
    
    await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
  }

  Future<String?> getToken() {
    return FirebaseAppCheck.instance.getToken();
  }
}
