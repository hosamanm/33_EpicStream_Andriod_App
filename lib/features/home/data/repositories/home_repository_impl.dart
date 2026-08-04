import '../../../movies/domain/entities/movie_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/genre_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<MovieEntity>> getHeroBanners() async {
    return await _remoteDataSource.getFeaturedMovies();
  }

  @override
  Future<List<MovieEntity>> getTrendingMovies() async {
    return await _remoteDataSource.getTrendingMovies();
  }

  @override
  Future<List<MovieEntity>> getPopularMovies() async {
    return await _remoteDataSource.getPopularMovies();
  }

  @override
  Future<List<MovieEntity>> getLatestMovies() async {
    return await _remoteDataSource.getLatestMovies();
  }

  @override
  Future<List<MovieEntity>> getRecommendedMovies(List<String> favoriteGenres) async {
    return await _remoteDataSource.getRecommendedMovies(favoriteGenres);
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<List<GenreEntity>> getGenres() async {
    return await _remoteDataSource.getGenres();
  }
}
