import '../../../../core/utils/result.dart';
import '../entities/admin_movie_entity.dart';

abstract class AdminMovieRepository {
  Future<Result<List<AdminMovieEntity>>> getMovies({int limit = 20, AdminMovieEntity? lastMovie});
  Future<Result<void>> addMovie(AdminMovieEntity movie);
  Future<Result<void>> updateMovie(AdminMovieEntity movie);
  Future<Result<void>> deleteMovie(String id);
  Future<Result<void>> togglePublish(String id, bool publish);
}
