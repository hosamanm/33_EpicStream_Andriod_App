import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart' as di;
import 'core/services/firebase_service.dart';
import 'core/error/error_handler.dart';
import 'firebase_options.dart';

void main() {
  // 1. Initialize Global Error Handling
  GlobalErrorHandler.init();
  
  // 2. Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  runZonedGuarded(() async {
    // 3. Initialize Firebase core
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 4. Initialize App Configuration
    AppConfig.init(
      apiBaseUrl: 'https://api.ottstream.com/v1',
      appName: 'EpicStream',
      environment: Environment.prod,
    );

    // 5. Initialize Dependency Injection
    await di.init();

    // 6. Initialize remaining Firebase services in background
    // We don't await this here to prevent blocking the initial app launch/splash
    scheduleMicrotask(() {
      di.sl<FirebaseService>().init();
    });

    runApp(const OttApp());
  }, (error, stack) {
    GlobalErrorHandler.recordError(error, stack, reason: 'Fatal Root Error');
  });
}
