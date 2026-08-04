import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/auth/presentation/providers/admin_auth_provider.dart';
import '../../features/auth/presentation/providers/admin_auth_state.dart';

/// Manages the admin session lifecycle.
class SessionManager {
  final AdminAuthProvider _authProvider;
  Timer? _refreshTimer;

  SessionManager(this._authProvider);

  /// Starts a periodic check or refresh logic if needed.
  /// Standard Firebase Auth handles persistence, but we might want to 
  /// periodically re-verify admin claims.
  void startSessionWatch() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      final state = _authProvider.state;
      if (state.status == AdminAuthStatus.authenticated && state.admin != null) {
        _authProvider.checkAdminPrivileges(state.admin!.uid);
      }
    });
  }

  void stopSessionWatch() {
    _refreshTimer?.cancel();
  }
}
