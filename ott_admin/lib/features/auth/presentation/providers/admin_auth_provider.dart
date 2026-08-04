import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_auth_state.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AdminRepository _repository;
  StreamSubscription? _authSubscription;

  AdminAuthProvider(this._repository) {
    _init();
  }

  AdminAuthState _state = AdminAuthState.initial();
  AdminAuthState get state => _state;

  void _init() {
    _authSubscription = _repository.authStateChanges.listen((user) async {
      if (user == null) {
        _updateState(AdminAuthState.unauthenticated());
      } else {
        await checkAdminPrivileges(user.uid);
      }
    });
  }

  void _updateState(AdminAuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> checkAdminPrivileges(String uid) async {
    _updateState(AdminAuthState.loading());
    final result = await _repository.getAdminData(uid);

    if (result.isSuccess) {
      final admin = result.data;
      if (admin != null && admin.isAdmin) {
        _updateState(AdminAuthState.authenticated(admin));
      } else {
        _updateState(AdminAuthState.unauthorized());
      }
    } else {
      _updateState(AdminAuthState.error(result.failure.message));
    }
  }

  Future<void> login(String email, String password) async {
    _updateState(AdminAuthState.loading());
    final result = await _repository.signIn(email, password);
    
    if (result.isError) {
      _updateState(AdminAuthState.error(result.failure.message));
    }
    // Success will be handled by the _init() listener
  }

  Future<void> logout() async {
    await _repository.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
