import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'app.dart';
import 'core/config/admin_config.dart';
import 'core/di/injection.dart' as di;

void main() async {
  // 1. Ensure bindings
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Wrap in Guarded Zone
  runZonedGuarded(() async {
    // 3. Initialize Firebase (Essential for Admin Auth/Firestore)
    // Pass platform-specific options here
    await Firebase.initializeApp();

    // 4. Initialize Config
    AdminConfig.init(
      apiBaseUrl: 'https://api.ottstream.com/admin/v1',
      appName: 'OTT Admin Panel',
      environment: AdminEnvironment.prod,
    );

    // 5. Initialize DI
    await di.init();

    runApp(const AdminApp());
  }, (error, stack) {
    debugPrint('FATAL ADMIN ERROR: $error');
    debugPrint(stack.toString());
  });
}
