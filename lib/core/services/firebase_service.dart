import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../di/injection.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import 'navigation_service.dart';

/// Centralized service to manage Firebase feature initialization and FCM.
class FirebaseService {
  final Logger _logger;
  late FlutterLocalNotificationsPlugin _localNotifications;

  FirebaseService(this._logger);

  Future<void> init() async {
    try {
      // 1. App Check - Critical for API Security
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode 
              ? AndroidProvider.debug 
              : AndroidProvider.playIntegrity,
        );
      } catch (e) {
        _logger.w('App Check failed: $e');
      }

      // 2. Crashlytics & Performance Monitoring
      if (!kIsWeb) {
        // Crashlytics for error reporting
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          return true;
        };
        
        // Performance Monitoring
        await FirebasePerformance.instance.setPerformanceCollectionEnabled(!kDebugMode);
      }

      // 3. Analytics
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

      // 4. Notification Setup
      await _initLocalNotifications();
      await _configureMessaging();

      _logger.i('Firebase production security & performance services initialized.');
    } catch (e, stack) {
      _logger.e('Firebase initialization error', error: e, stackTrace: stack);
    }
  }

  Future<void> _initLocalNotifications() async {
    _localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          _handleDeepLink(details.payload!);
        }
      },
    );

    const channel = AndroidNotificationChannel(
      'epicstream_main',
      'EpicStream Notifications',
      description: 'Main channel for new movies and announcements',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _configureMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    String? token = await messaging.getToken();
    if (token != null) {
      try {
        await sl<NotificationRepository>().updateFcmToken(token);
      } catch (_) {}
    }

    messaging.onTokenRefresh.listen((newToken) {
      try {
        sl<NotificationRepository>().updateFcmToken(newToken);
      } catch (_) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['deepLink'] != null) {
        _handleDeepLink(message.data['deepLink']);
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'epicstream_main',
            'EpicStream Notifications',
            icon: android?.smallIcon,
          ),
        ),
        payload: message.data['deepLink'],
      );
    }
  }

  void _handleDeepLink(String deepLink) {
    sl<NavigationService>().navigateTo(deepLink);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
