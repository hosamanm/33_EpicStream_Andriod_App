import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/data/models/movie_model.dart';

/// Advanced Search Service for OTT content.
/// Supports filtering, sorting, and cursor-based pagination.
class SearchService {
  final FirebaseFirestore _firestore;

  SearchService(this._firestore);

  /// Performs a complex search query with filters and sorting.
  Future<List<MovieEntity>> searchMovies({
    required String query,
    String? genreId,
    String? language,
    String? year,
    double? minRating,
    String sortBy = 'relevance',
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query movieQuery = _firestore.collection('movies');

    // 1. Text Search Logic (Title / Keywords)
    if (query.isNotEmpty) {
      // Using searchKeywords array for multi-field discovery (Cast, Director, Title)
      // This requires the 'searchKeywords' field to be populated in Firestore
      movieQuery = movieQuery.where('searchKeywords', arrayContains: query.toLowerCase());
    }

    // 2. Applying Filters
    if (genreId != null) {
      movieQuery = movieQuery.where('genreIds', arrayContains: genreId);
    }
    if (language != null) {
      movieQuery = movieQuery.where('language', isEqualTo: language);
    }
    if (year != null) {
      movieQuery = movieQuery.where('releaseYear', isEqualTo: int.parse(year));
    }
    if (minRating != null && minRating > 0) {
      movieQuery = movieQuery.where('imdbRating', isGreaterThanOrEqualTo: minRating);
    }

    // 3. Sorting (Requires Composite Indexes in Firestore)
    switch (sortBy) {
      case 'newest':
        movieQuery = movieQuery.orderBy('releaseYear', descending: true);
        break;
      case 'rating':
        movieQuery = movieQuery.orderBy('imdbRating', descending: true);
        break;
      case 'popular':
        movieQuery = movieQuery.orderBy('viewCount', descending: true);
        break;
      default:
        // Relevance usually follows the created date or alphabetical if keywords are used
        movieQuery = movieQuery.orderBy('updatedAt', descending: true);
    }

    // 4. Pagination
    if (lastDocument != null) {
      movieQuery = movieQuery.startAfterDocument(lastDocument);
    }

    final snapshot = await movieQuery.limit(limit).get();
    
    return snapshot.docs
        .map((doc) => MovieModel.fromFirestore(doc))
        .toList();
  }

  /// Fetches real-time trending searches from a dedicated collection.
  Future<List<String>> getTrendingSearches() async {
    final snapshot = await _firestore
        .collection('trending_searches')
        .orderBy('searchCount', descending: true)
        .limit(10)
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// Increments search count for trending analytics.
  Future<void> logSearchQuery(String query) async {
    if (query.isEmpty) return;
    final docRef = _firestore.collection('trending_searches').doc(query.toLowerCase().trim());
    await docRef.set({
      'query': query,
      'searchCount': FieldValue.increment(1),
      'lastSearched': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
