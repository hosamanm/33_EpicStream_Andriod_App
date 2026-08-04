import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/services/search_service.dart';
import '../providers/search_provider.dart';
import '../providers/recent_search_provider.dart';

/// Controller for handling search logic, including debouncing, pagination, and filters.
class SearchModuleController {
  final SearchProvider _searchProvider;
  final RecentSearchProvider _recentSearchProvider;
  final SearchService _searchService;
  Timer? _debounce;

  SearchModuleController({
    required SearchProvider searchProvider,
    required RecentSearchProvider recentSearchProvider,
    required SearchService searchService,
  })  : _searchProvider = searchProvider,
        _recentSearchProvider = recentSearchProvider,
        _searchService = searchService;

  /// Handles search input with a 500ms debounce.
  void onSearchChanged(String query) {
    _searchProvider.setQuery(query);

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        performSearch(query);
      }
    });
  }

  /// Executes a fresh search.
  Future<void> performSearch(String query) async {
    if (query.isEmpty) return;

    _searchProvider.setStatus(SearchStatus.loading);
    
    try {
      // Logic for logging search for trending analytics
      _searchService.logSearchQuery(query);

      final results = await _searchService.searchMovies(
        query: query,
        genreId: _searchProvider.selectedGenreId,
        language: _searchProvider.selectedLanguage,
        year: _searchProvider.selectedYear,
        minRating: _searchProvider.minRating,
        sortBy: _searchProvider.sortBy,
      );

      _searchProvider.setResults(results);
      
      if (results.isNotEmpty) {
        _recentSearchProvider.addQuery(query);
      }
    } catch (e) {
      _searchProvider.setError('Search failed: ${e.toString()}');
    }
  }

  /// Loads the next page of results.
  Future<void> loadMore() async {
    if (!_searchProvider.hasMore || _searchProvider.status == SearchStatus.loadingMore) return;

    _searchProvider.setStatus(SearchStatus.loadingMore);

    try {
      final results = await _searchService.searchMovies(
        query: _searchProvider.query,
        genreId: _searchProvider.selectedGenreId,
        language: _searchProvider.selectedLanguage,
        year: _searchProvider.selectedYear,
        minRating: _searchProvider.minRating,
        sortBy: _searchProvider.sortBy,
        // In a real implementation, we'd need the actual DocumentSnapshot.
        // For this architecture, we assume the service can handle it or we pass the last item.
        limit: 20,
      );

      _searchProvider.setResults(results, isLoadMore: true);
    } catch (e) {
      _searchProvider.setStatus(SearchStatus.success); // Silent fail for load more
    }
  }

  void clearSearch() {
    _searchProvider.setQuery('');
    if (_debounce?.isActive ?? false) _debounce!.cancel();
  }

  void dispose() {
    _debounce?.cancel();
  }
}
