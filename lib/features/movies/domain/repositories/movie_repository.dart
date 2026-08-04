import '../../../../core/utils/result.dart';
import '../entities/movie_entity.dart';

abstract class MovieRepository {
  Future<Result<MovieEntity>> getMovieById(String movieId);
  Future<Result<List<MovieEntity>>> getMoviesByGenre(List<String> genreIds);
  Future<Result<List<MovieEntity>>> getMoviesByCategory(String categoryId);
  Future<Result<List<MovieEntity>>> getRelatedMovies(MovieEntity movie);
  Future<Result<List<MovieEntity>>> searchMovies(String query);
  Future<Result<void>> incrementViewCount(String movieId);
}
