import '../../../../core/repositories/repository_base.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_remote_datasource.dart';

class MovieRepositoryImpl extends RepositoryBase implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl(
    this._remoteDataSource,
    {
      required super.cacheService,
      required super.retryPolicy,
      required super.logger,
    }
  );

  @override
  Future<Result<MovieEntity>> getMovieById(String movieId) async {
    return safeCall(
      request: () async {
        final movie = await _remoteDataSource.getMovieById(movieId);
        if (movie == null) throw Exception('Movie not found');
        return movie;
      },
      cacheKey: 'movie_$movieId',
    );
  }

  @override
  Future<Result<List<MovieEntity>>> getMoviesByGenre(List<String> genreIds) async {
    return safeCall(
      request: () => _remoteDataSource.getMoviesByGenre(genreIds),
      cacheKey: 'movies_genre_${genreIds.join('_')}',
    );
  }

  @override
  Future<Result<List<MovieEntity>>> getMoviesByCategory(String categoryId) async {
    return safeCall(
      request: () => _remoteDataSource.getMoviesByCategory(categoryId),
      cacheKey: 'movies_cat_$categoryId',
    );
  }

  @override
  Future<Result<List<MovieEntity>>> getRelatedMovies(MovieEntity movie) async {
    return safeCall(
      request: () async {
        final movies = await _remoteDataSource.getMoviesByGenre(movie.genreIds);
        return movies
            .where((m) => m.movieId != movie.movieId)
            .take(10)
            .toList();
      },
      cacheKey: 'related_${movie.movieId}',
    );
  }

  @override
  Future<Result<List<MovieEntity>>> searchMovies(String query) async {
    // We don't cache search results for long usually
    return safeCall(
      request: () => _remoteDataSource.searchMovies(query),
      useRetry: false, 
    );
  }

  @override
  Future<Result<void>> incrementViewCount(String movieId) async {
    return safeCall(
      request: () => _remoteDataSource.incrementViewCount(movieId),
      useRetry: true,
    );
  }
}
