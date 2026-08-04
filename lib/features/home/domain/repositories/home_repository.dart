import '../../../movies/domain/entities/movie_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/genre_entity.dart';

abstract class HomeRepository {
  Future<List<MovieEntity>> getHeroBanners();
  Future<List<MovieEntity>> getTrendingMovies();
  Future<List<MovieEntity>> getPopularMovies();
  Future<List<MovieEntity>> getLatestMovies();
  Future<List<MovieEntity>> getRecommendedMovies(List<String> favoriteGenres);
  Future<List<CategoryEntity>> getCategories();
  Future<List<GenreEntity>> getGenres();
}
