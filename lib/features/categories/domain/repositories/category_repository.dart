import '../../domain/entities/category_entity.dart';
import '../../domain/entities/genre_entity.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<List<GenreEntity>> getGenres();
}
