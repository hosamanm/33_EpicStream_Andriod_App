import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../movies/domain/entities/movie_entity.dart';

enum SearchStatus { idle, loading, success, loadingMore, noResults, error }

class SearchProvider extends ChangeNotifier {
  SearchStatus _status = SearchStatus.idle;
  SearchStatus get status => _status;

  List<MovieEntity> _results = [];
  List<MovieEntity> get results => _results;

  String _query = '';
  String get query => _query;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Pagination
  DocumentSnapshot? lastDocument;
  bool hasMore = true;

  // Filters
  String? selectedGenreId;
  String? selectedLanguage;
  String? selectedYear;
  double minRating = 0;
  String sortBy = 'relevance';

  void setQuery(String query) {
    _query = query;
    if (query.isEmpty) {
      _status = SearchStatus.idle;
      _results = [];
      lastDocument = null;
      hasMore = true;
    }
    notifyListeners();
  }

  void setStatus(SearchStatus status) {
    _status = status;
    notifyListeners();
  }

  void setResults(List<MovieEntity> results, {bool isLoadMore = false, DocumentSnapshot? lastDoc}) {
    if (isLoadMore) {
      _results.addAll(results);
      _status = SearchStatus.success;
    } else {
      _results = results;
      _status = results.isEmpty ? SearchStatus.noResults : SearchStatus.success;
    }
    
    lastDocument = lastDoc;
    hasMore = results.length == 20; // Assuming limit is 20
    notifyListeners();
  }

  void setError(String message) {
    _errorMessage = message;
    _status = SearchStatus.error;
    notifyListeners();
  }

  void updateFilters({
    String? genreId,
    String? language,
    String? year,
    double? rating,
    String? sort,
  }) {
    selectedGenreId = genreId ?? selectedGenreId;
    selectedLanguage = language ?? selectedLanguage;
    selectedYear = year ?? selectedYear;
    minRating = rating ?? minRating;
    sortBy = sort ?? sortBy;
    notifyListeners();
  }

  void resetFilters() {
    selectedGenreId = null;
    selectedLanguage = null;
    selectedYear = null;
    minRating = 0;
    sortBy = 'relevance';
    notifyListeners();
  }
}
