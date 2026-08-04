import 'package:flutter/material.dart';

enum PasswordStrength { empty, weak, medium, strong }

/// Manages the local UI state for the Registration screen.
/// Handles validation of passwords and terms acceptance.
class RegisterNotifier extends ChangeNotifier {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  PasswordStrength _passwordStrength = PasswordStrength.empty;

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get acceptTerms => _acceptTerms;
  PasswordStrength get passwordStrength => _passwordStrength;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }

  /// Evaluates password strength based on length and complexity.
  void checkPasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = PasswordStrength.empty;
    } else if (password.length < 6) {
      _passwordStrength = PasswordStrength.weak;
    } else if (RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(password)) {
      _passwordStrength = PasswordStrength.strong;
    } else {
      _passwordStrength = PasswordStrength.medium;
    }
    notifyListeners();
  }
}
