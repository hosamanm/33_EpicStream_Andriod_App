import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/repositories/category_repository.dart';

/// High-level service to orchestrate category, genre, and language operations.
class CategoryService {
  final CategoryRepository _repository;

  CategoryService(this._repository);

  // --- Categories ---
  Future<List<AdminCategoryEntity>> fetchCategories() async {
    final result = await _repository.getCategories();
    if (result.isSuccess) return result.data;
    throw Exception(result.failure.message);
  }

  Future<void> saveCategory(AdminCategoryEntity category) async {
    final result = category.id.isEmpty 
        ? await _repository.addCategory(category) 
        : await _repository.updateCategory(category);
    if (result.isError) throw Exception(result.failure.message);
  }

  Future<void> deleteCategory(String id) async {
    final result = await _repository.deleteCategory(id);
    if (result.isError) throw Exception(result.failure.message);
  }

  // --- Genres ---
  Future<List<GenreEntity>> fetchGenres() async {
    final result = await _repository.getGenres();
    if (result.isSuccess) return result.data;
    throw Exception(result.failure.message);
  }

  Future<void> saveGenre(GenreEntity genre) async {
    final result = genre.id.isEmpty 
        ? await _repository.addGenre(genre) 
        : await _repository.updateGenre(genre);
    if (result.isError) throw Exception(result.failure.message);
  }

  Future<void> deleteGenre(String id) async {
    final result = await _repository.deleteGenre(id);
    if (result.isError) throw Exception(result.failure.message);
  }

  // --- Languages ---
  Future<List<LanguageEntity>> fetchLanguages() async {
    final result = await _repository.getLanguages();
    if (result.isSuccess) return result.data;
    throw Exception(result.failure.message);
  }

  Future<void> saveLanguage(LanguageEntity language) async {
    final result = language.id.isEmpty 
        ? await _repository.addLanguage(language) 
        : await _repository.updateLanguage(language);
    if (result.isError) throw Exception(result.failure.message);
  }

  Future<void> deleteLanguage(String id) async {
    final result = await _repository.deleteLanguage(id);
    if (result.isError) throw Exception(result.failure.message);
  }
}
