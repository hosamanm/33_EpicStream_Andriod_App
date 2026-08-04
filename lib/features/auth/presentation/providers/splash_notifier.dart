import 'dart:async';
import 'package:flutter/material.dart';
import 'package:epic_stream/core/services/connectivity_service.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_state.dart';

enum SplashStep { idle, initializing, completed }

class SplashNotifier extends ChangeNotifier {
  final AuthNotifier _authNotifier;
  final ConnectivityService _connectivityService;

  SplashStep _step = SplashStep.idle;
  SplashStep get step => _step;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Exact duration requested: 6 seconds
  static const Duration _minSplashDuration = Duration(seconds: 6);
  bool _isInitialized = false;

  SplashNotifier({
    required AuthNotifier authNotifier,
    required ConnectivityService connectivityService,
  })  : _authNotifier = authNotifier,
        _connectivityService = connectivityService;

  Future<void> initializeApp() async {
    if (_isInitialized) return;
    _isInitialized = true;

    debugPrint('SplashNotifier: STARTING INITIALIZATION (Target: 6s)');
    final startTime = DateTime.now();
    _updateStep(SplashStep.initializing);

    // Global Fail-Safe: transition after 12 seconds no matter what
    Timer(const Duration(seconds: 12), () {
      if (_step != SplashStep.completed) {
        debugPrint('SplashNotifier: GLOBAL FAIL-SAFE TRIGGERED. Forcing transition.');
        _updateStep(SplashStep.completed);
      }
    });

    try {
      // 1. Parallel background checks with safety timeouts
      await Future.wait([
        _connectivityService.checkConnectivity()
            .timeout(const Duration(seconds: 3))
            .catchError((e) {
              debugPrint('SplashNotifier: Connectivity check issue: $e');
              return ConnectivityStatus.wifi;
            }),
        _authNotifier.checkAuthStatus()
            .timeout(const Duration(seconds: 6))
            .catchError((e) {
              debugPrint('SplashNotifier: Auth check issue: $e');
              return null;
            }),
      ]);

      // 2. Synchronize with cinematic animation duration
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < _minSplashDuration) {
        final remaining = _minSplashDuration - elapsed;
        debugPrint('SplashNotifier: Waiting ${remaining.inMilliseconds}ms for animation sync');
        await Future.delayed(remaining);
      }

      debugPrint('SplashNotifier: Initialization complete.');
      _updateStep(SplashStep.completed);
    } catch (e) {
      debugPrint('SplashNotifier: Unexpected critical error during init: $e');
      _updateStep(SplashStep.completed); // Proceed anyway to avoid stuck app
    }
  }

  void _updateStep(SplashStep newStep) {
    if (_step == newStep) return;
    _step = newStep;
    notifyListeners();
  }
}
