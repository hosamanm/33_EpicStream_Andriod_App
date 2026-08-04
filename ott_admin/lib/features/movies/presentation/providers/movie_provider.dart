import 'package:flutter/material.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../../domain/repositories/admin_movie_repository.dart';

enum MovieManagementStatus { initial, loading, loaded, error }

class AdminMovieProvider extends ChangeNotifier {
  final AdminMovieRepository _repository;

  AdminMovieProvider(this._repository);

  MovieManagementStatus _status = MovieManagementStatus.initial;
  MovieManagementStatus get status => _status;

  List<AdminMovieEntity> _movies = [];
  List<AdminMovieEntity> get movies => _movies;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> fetchMovies({bool isRefresh = false}) async {
    if (isRefresh) _movies = [];
    _status = MovieManagementStatus.loading;
    notifyListeners();

    final result = await _repository.getMovies();

    if (result.isSuccess) {
      _movies = result.data!;
      _status = MovieManagementStatus.loaded;
    } else {
      _errorMessage = result.failure.message;
      _status = MovieManagementStatus.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<AdminMovieEntity> get filteredMovies {
    if (_searchQuery.isEmpty) return _movies;
    return _movies.where((movie) => 
      movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (movie.originalTitle?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
    ).toList();
  }

  Future<void> deleteMovie(String id) async {
    final movie = _movies.firstWhere((m) => m.id == id);
    final result = await _repository.deleteMovie(id);
    if (result.isSuccess) {
      _movies.removeWhere((m) => m.id == id);
      notifyListeners();
    }
  }

  Future<void> togglePublish(String id, bool publish) async {
    final result = await _repository.togglePublish(id, publish);
    if (result.isSuccess) {
      final index = _movies.indexWhere((m) => m.id == id);
      if (index != -1) {
        _movies[index] = _movies[index].copyWith(
          status: publish ? AdminMovieStatus.published : AdminMovieStatus.draft,
        );
        notifyListeners();
      }
    }
  }
}
