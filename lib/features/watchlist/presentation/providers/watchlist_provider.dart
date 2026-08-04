import 'dart:async';
import 'package:flutter/material.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../domain/repositories/watchlist_repository.dart';

enum WatchlistStatus { initial, loading, loaded, error }
enum WatchlistSort { newest, oldest, alphabetical }

class WatchlistProvider extends ChangeNotifier {
  final WatchlistRepository _repository;
  StreamSubscription? _watchlistSubscription;

  WatchlistProvider(this._repository);

  WatchlistStatus _status = WatchlistStatus.initial;
  WatchlistStatus get status => _status;

  List<MovieEntity> _allMovies = [];
  List<MovieEntity> _filteredMovies = [];
  List<MovieEntity> get movies => _filteredMovies;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  WatchlistSort _currentSort = WatchlistSort.newest;

  void init() {
    _status = WatchlistStatus.loading;
    notifyListeners();

    _watchlistSubscription?.cancel();
    _watchlistSubscription = _repository.watchWatchlist().listen(
      (movies) {
        _allMovies = movies;
        _applyFilters();
        _status = WatchlistStatus.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _status = WatchlistStatus.error;
        notifyListeners();
      },
    );
  }

  // Fallback for manual refresh/pull-to-refresh
  Future<void> fetchWatchlist() async {
    _status = WatchlistStatus.loading;
    notifyListeners();

    final result = await _repository.getWatchlist();
    
    if (result.isSuccess) {
      _allMovies = result.data!;
      _applyFilters();
      _status = WatchlistStatus.loaded;
    } else {
      _errorMessage = result.failure.message;
      _status = WatchlistStatus.error;
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSort(WatchlistSort sort) {
    _currentSort = sort;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredMovies = List.from(_allMovies);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      _filteredMovies = _filteredMovies
          .where((m) => m.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Sorting
    switch (_currentSort) {
      case WatchlistSort.newest:
        // Already sorted by addedAt from repository/Firestore
        break;
      case WatchlistSort.oldest:
        _filteredMovies = _filteredMovies.reversed.toList();
        break;
      case WatchlistSort.alphabetical:
        _filteredMovies.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
  }

  @override
  void dispose() {
    _watchlistSubscription?.cancel();
    super.dispose();
  }
}
