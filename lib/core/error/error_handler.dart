import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../di/injection.dart';

/// Global Error Handler to catch and report all uncaught exceptions.
class GlobalErrorHandler {
  static void init() {
    // Catch Flutter Framework Errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _reportError(details.exception, details.stack);
    };

    // Catch Asynchronous Errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _reportError(error, stack);
      return true;
    };
  }

  static void _reportError(dynamic error, StackTrace? stack) {
    sl<Logger>().e('Uncaught Error', error: error, stackTrace: stack);
    
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  }

  static void recordError(dynamic error, StackTrace? stack, {String? reason}) {
    sl<Logger>().e('Recorded Error: $reason', error: error, stackTrace: stack);
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
    }
  }
}
