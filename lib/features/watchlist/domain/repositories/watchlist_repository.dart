import '../../../../core/utils/result.dart';
import '../../../movies/domain/entities/movie_entity.dart';

abstract class WatchlistRepository {
  Future<Result<void>> addToWatchlist(String movieId);
  Future<Result<void>> removeFromWatchlist(String movieId);
  Future<Result<bool>> isInWatchlist(String movieId);
  Future<Result<List<MovieEntity>>> getWatchlist();
  Stream<List<MovieEntity>> watchWatchlist();
}
