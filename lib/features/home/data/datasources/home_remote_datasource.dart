import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/genre_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies();
  Future<List<MovieModel>> getPopularMovies();
  Future<List<MovieModel>> getLatestMovies();
  Future<List<MovieModel>> getRecommendedMovies(List<String> favoriteGenres);
  Future<List<MovieModel>> getFeaturedMovies();
  Future<List<CategoryModel>> getCategories();
  Future<List<GenreModel>> getGenres();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<MovieModel>> getTrendingMovies() async {
    final snapshot = await _firestore
        .collection('movies')
        .where('isTrending', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> getPopularMovies() async {
    final snapshot = await _firestore
        .collection('movies')
        .orderBy('imdbRating', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> getLatestMovies() async {
    final snapshot = await _firestore
        .collection('movies')
        .orderBy('releaseYear', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> getRecommendedMovies(List<String> favoriteGenres) async {
    if (favoriteGenres.isEmpty) {
      return getPopularMovies();
    }
    final snapshot = await _firestore
        .collection('movies')
        .where('genreIds', arrayContainsAny: favoriteGenres)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<MovieModel>> getFeaturedMovies() async {
    final snapshot = await _firestore
        .collection('movies')
        .where('isFeatured', isEqualTo: true)
        .limit(5)
        .get();
    return snapshot.docs.map((doc) => MovieModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore
        .collection('categories')
        .orderBy('priority', descending: false)
        .get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    final snapshot = await _firestore
        .collection('genres')
        .orderBy('name', descending: false)
        .get();
    return snapshot.docs.map((doc) => GenreModel.fromFirestore(doc)).toList();
  }
}
