import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';

/// Manages the user session lifecycle.
/// Handles inactivity timeouts and global session expiration.
class SessionManager {
  final AuthNotifier _authNotifier;
  Timer? _inactivityTimer;
  
  // Configuration for 1M+ users: Security vs UX balance
  static const Duration inactivityLimit = Duration(minutes: 30);
  static const Duration sessionMaxLifetime = Duration(days: 7);

  SessionManager(this._authNotifier);

  /// Called whenever a user interacts with the app.
  void recordUserActivity() {
    if (_authNotifier.state is! Authenticated) return;

    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(inactivityLimit, () {
      _handleInactivityTimeout();
    });
  }

  void _handleInactivityTimeout() {
    // In a production OTT app, we might just refresh the token or 
    // show a "Still watching?" prompt. Here we implement a secure logout.
    if (_authNotifier.state is Authenticated) {
      _authNotifier.logout();
    }
  }

  void clearSession() {
    _inactivityTimer?.cancel();
  }
}
