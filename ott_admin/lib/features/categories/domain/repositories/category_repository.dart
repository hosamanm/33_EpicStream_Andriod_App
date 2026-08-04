import 'dart:typed_data';
import '../../../../core/utils/result.dart';
import '../entities/admin_category_entity.dart';
import '../entities/genre_entity.dart';
import '../entities/language_entity.dart';
import '../entities/country_entity.dart';
import '../entities/age_rating_entity.dart';
import '../entities/home_section_entity.dart';

abstract class CategoryRepository {
  // Category CRUD
  Future<Result<List<AdminCategoryEntity>>> getCategories();
  Future<Result<void>> addCategory(AdminCategoryEntity category, {Uint8List? image, Uint8List? icon});
  Future<Result<void>> updateCategory(AdminCategoryEntity category, {Uint8List? image, Uint8List? icon});
  Future<Result<void>> deleteCategory(String id);
  Future<Result<void>> reorderCategories(List<String> ids);

  // Genre CRUD
  Future<Result<List<GenreEntity>>> getGenres();
  Future<Result<void>> addGenre(GenreEntity genre, {Uint8List? image});
  Future<Result<void>> updateGenre(GenreEntity genre, {Uint8List? image});
  Future<Result<void>> deleteGenre(String id);

  // Language CRUD
  Future<Result<List<LanguageEntity>>> getLanguages();
  Future<Result<void>> addLanguage(LanguageEntity language, {Uint8List? icon});
  Future<Result<void>> updateLanguage(LanguageEntity language, {Uint8List? icon});
  Future<Result<void>> deleteLanguage(String id);

  // Country CRUD
  Future<Result<List<CountryEntity>>> getCountries();
  Future<Result<void>> addCountry(CountryEntity country, {Uint8List? flag});
  Future<Result<void>> updateCountry(CountryEntity country, {Uint8List? flag});
  Future<Result<void>> deleteCountry(String id);

  // Age Rating CRUD
  Future<Result<List<AgeRatingEntity>>> getAgeRatings();
  Future<Result<void>> addAgeRating(AgeRatingEntity rating, {Uint8List? icon});
  Future<Result<void>> updateAgeRating(AgeRatingEntity rating, {Uint8List? icon});
  Future<Result<void>> deleteAgeRating(String id);

  // Home Section CRUD
  Future<Result<List<HomeSectionEntity>>> getHomeSections();
  Future<Result<void>> addHomeSection(HomeSectionEntity section, {Uint8List? banner});
  Future<Result<void>> updateHomeSection(HomeSectionEntity section, {Uint8List? banner});
  Future<Result<void>> deleteHomeSection(String id);
  Future<Result<void>> reorderHomeSections(List<String> ids);
}
