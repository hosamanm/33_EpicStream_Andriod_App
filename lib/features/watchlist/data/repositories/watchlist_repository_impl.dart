import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/error/failures.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/data/models/movie_model.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_remote_datasource.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistRemoteDataSource _remoteDataSource;
  final FirebaseFirestore _firestore;

  WatchlistRepositoryImpl(this._remoteDataSource, this._firestore);

  @override
  Future<Result<void>> addToWatchlist(String movieId) async {
    try {
      await _remoteDataSource.addToWatchlist(movieId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFromWatchlist(String movieId) async {
    try {
      await _remoteDataSource.removeFromWatchlist(movieId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isInWatchlist(String movieId) async {
    try {
      final exists = await _remoteDataSource.isInWatchlist(movieId);
      return Result.success(exists);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<MovieEntity>>> getWatchlist() async {
    try {
      final movies = await _remoteDataSource.getWatchlist();
      return Result.success(movies);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<MovieEntity>> watchWatchlist() {
    // This implementation watches the IDs and then fetches the movie details.
    // For production-grade performance, consider denormalizing movie data into the watchlist document.
    return _remoteDataSource.watchWatchlistIds().asyncMap((ids) async {
      if (ids.isEmpty) return [];
      
      // Firestore whereIn limit is 30. For larger lists, this needs chunking.
      final snapshots = await _firestore
          .collection('movies')
          .where(FieldPath.documentId, whereIn: ids.take(30).toList())
          .get();

      final movieMap = {for (var doc in snapshots.docs) doc.id: MovieModel.fromFirestore(doc)};
      return ids.map((id) => movieMap[id]).whereType<MovieModel>().toList();
    });
  }
}
