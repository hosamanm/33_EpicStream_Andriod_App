import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/playback_progress_entity.dart';
import '../../domain/repositories/player_progress_repository.dart';

/// Provider for managing the full "Watch History" state.
/// Provides a real-time stream of all playback items, sorted by time.
class HistoryProvider extends ChangeNotifier {
  final PlayerProgressRepository _repository;
  StreamSubscription? _subscription;

  List<PlaybackProgressEntity> _historyItems = [];
  List<PlaybackProgressEntity> get historyItems => _historyItems;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  HistoryProvider(this._repository) {
    _init();
  }

  void _init() {
    _subscription = _repository.watchWatchHistory().listen((data) {
      _historyItems = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> clearItem(String movieId) async {
    await _repository.deleteProgress(movieId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
