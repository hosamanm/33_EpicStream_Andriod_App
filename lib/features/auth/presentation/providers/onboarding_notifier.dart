import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier to manage the Onboarding state and persistence.
class OnboardingNotifier extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _onboardingKey = 'has_seen_onboarding';

  OnboardingNotifier(this._prefs);

  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;

  /// Marks the onboarding as completed in local storage.
  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }
}
