import 'package:flutter/material.dart';

/// Provider to manage the state of the Main Dashboard.
/// Handles current tab index and badge counts for specific tabs.
class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  // Example badge counts (e.g., for Downloads or Profile notifications)
  int _downloadBadgeCount = 0;
  int get downloadBadgeCount => _downloadBadgeCount;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void setDownloadBadge(int count) {
    _downloadBadgeCount = count;
    notifyListeners();
  }

  /// Reset to Home tab (useful for deep linking or session reset)
  void resetToHome() {
    _currentIndex = 0;
    notifyListeners();
  }
}
