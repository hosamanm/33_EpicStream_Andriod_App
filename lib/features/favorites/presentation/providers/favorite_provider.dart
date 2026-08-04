import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';

enum FavoriteTab { movies, actors, directors }

class FavoriteProvider extends ChangeNotifier {
  final FavoriteRepository _repository;
  StreamSubscription? _subscription;

  FavoriteProvider(this._repository);

  List<FavoriteEntity> _allFavorites = [];
  List<FavoriteEntity> _filteredFavorites = [];
  List<FavoriteEntity> get favorites => _filteredFavorites;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  FavoriteTab _currentTab = FavoriteTab.movies;
  FavoriteTab get currentTab => _currentTab;

  String _searchQuery = '';

  void init() {
    _isLoading = true;
    _subscription?.cancel();
    _subscription = _repository.watchFavorites().listen((data) {
      _allFavorites = data;
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void setTab(FavoriteTab tab) {
    _currentTab = tab;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    // 1. Filter by Tab
    List<FavoriteEntity> temp;
    switch (_currentTab) {
      case FavoriteTab.movies:
        temp = _allFavorites.where((f) => f.type == 'movie' || f.type == 'tv_show').toList();
        break;
      case FavoriteTab.actors:
        temp = _allFavorites.where((f) => f.type == 'actor').toList();
        break;
      case FavoriteTab.directors:
        temp = _allFavorites.where((f) => f.type == 'director').toList();
        break;
    }

    // 2. Search
    if (_searchQuery.isNotEmpty) {
      temp = temp.where((f) => f.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    _filteredFavorites = temp;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
