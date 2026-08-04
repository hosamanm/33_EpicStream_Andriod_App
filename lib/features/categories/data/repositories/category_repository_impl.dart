import '../../domain/entities/category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;

  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<List<GenreEntity>> getGenres() async {
    return await _remoteDataSource.getGenres();
  }
}
