import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

abstract class MovieRemoteDataSource {
  Future<MovieModel?> getMovieById(String movieId);
  Future<List<MovieModel>> getMoviesByGenre(List<String> genreIds);
  Future<List<MovieModel>> getMoviesByCategory(String categoryId);
  Future<List<MovieModel>> searchMovies(String query);
  Future<void> incrementViewCount(String movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'movies';

  MovieRemoteDataSourceImpl(this._firestore);

  @override
  Future<MovieModel?> getMovieById(String movieId) async {
    final doc = await _firestore.collection(_collection).doc(movieId).get();
    if (!doc.exists) return null;
    return MovieModel.fromFirestore(doc);
  }

  @override
  Future<List<MovieModel>> getMoviesByGenre(List<String> genreIds) async {
    if (genreIds.isEmpty) return [];
    
    // Firestore 'array-contains-any' allows matching any of up to 10 values.
    final snapshot = await _firestore
        .collection(_collection)
        .where('genreIds', arrayContainsAny: genreIds.take(10).toList())
        .orderBy('releaseYear', descending: true)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> getMoviesByCategory(String categoryId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('releaseYear', descending: true)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> incrementViewCount(String movieId) async {
    await _firestore.collection(_collection).doc(movieId).update({
      'viewCount': FieldValue.increment(1),
    });
  }
}
