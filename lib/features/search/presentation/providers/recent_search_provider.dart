import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the local history of search queries.
class RecentSearchProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const String _key = 'recent_searches';
  List<String> _history = [];

  RecentSearchProvider(this._prefs) {
    _loadHistory();
  }

  List<String> get history => _history;

  void _loadHistory() {
    _history = _prefs.getStringList(_key) ?? [];
    notifyListeners();
  }

  Future<void> addQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    _history.remove(query); // Remove if exists to move to top
    _history.insert(0, query);
    
    if (_history.length > 10) {
      _history = _history.sublist(0, 10); // Keep last 10
    }
    
    await _prefs.setStringList(_key, _history);
    notifyListeners();
  }

  Future<void> removeQuery(String query) async {
    _history.remove(query);
    await _prefs.setStringList(_key, _history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history.clear();
    await _prefs.remove(_key);
    notifyListeners();
  }
}
