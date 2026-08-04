import 'package:flutter/material.dart';
import '../providers/admin_auth_provider.dart';

/// Controller for the Admin Authentication module.
/// Decouples the UI from the provider logic.
class AdminAuthController {
  final AdminAuthProvider _provider;

  AdminAuthController(this._provider);

  Future<void> login(String email, String password) async {
    await _provider.login(email, password);
  }

  Future<void> logout() async {
    await _provider.logout();
  }

  Future<void> forgotPassword(String email) async {
    await _provider.resetPassword(email);
  }
}
