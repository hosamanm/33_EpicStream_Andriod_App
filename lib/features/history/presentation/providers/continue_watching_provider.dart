import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/playback_progress_entity.dart';
import '../../domain/repositories/player_progress_repository.dart';

/// Provider for managing the "Continue Watching" state.
/// Listens to a real-time stream of incomplete playback items.
class ContinueWatchingProvider extends ChangeNotifier {
  final PlayerProgressRepository _repository;
  StreamSubscription? _subscription;

  List<PlaybackProgressEntity> _items = [];
  List<PlaybackProgressEntity> get items => _items;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ContinueWatchingProvider(this._repository) {
    _init();
  }

  void _init() {
    _subscription = _repository.watchContinueWatching().listen((data) {
      _items = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
