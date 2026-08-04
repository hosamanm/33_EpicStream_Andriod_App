import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/age_rating_entity.dart';
import '../../domain/entities/home_section_entity.dart';
import '../../domain/repositories/category_repository.dart';

enum CategoryManagementStatus { initial, loading, loaded, error }

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  CategoryManagementStatus _status = CategoryManagementStatus.initial;
  CategoryManagementStatus get status => _status;

  // Data
  List<AdminCategoryEntity> _categories = [];
  List<GenreEntity> _genres = [];
  List<LanguageEntity> _languages = [];
  List<CountryEntity> _countries = [];
  List<AgeRatingEntity> _ageRatings = [];
  List<HomeSectionEntity> _homeSections = [];

  List<AdminCategoryEntity> get categories => _categories;
  List<GenreEntity> get genres => _genres;
  List<LanguageEntity> get languages => _languages;
  List<CountryEntity> get countries => _countries;
  List<AgeRatingEntity> get ageRatings => _ageRatings;
  List<HomeSectionEntity> get homeSections => _homeSections;

  String _searchQuery = '';
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _status = CategoryManagementStatus.loading;
    notifyListeners();
    try {
      await Future.wait([
        fetchCategories(),
        fetchGenres(),
        fetchLanguages(),
        fetchCountries(),
        fetchAgeRatings(),
        fetchHomeSections(),
      ]);
      _status = CategoryManagementStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = CategoryManagementStatus.error;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  List<AdminCategoryEntity> get filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((c) => c.name.toLowerCase().contains(_searchQuery)).toList();
  }

  // --- Actions ---
  Future<void> fetchCategories() async {
    final result = await _repository.getCategories();
    if (result.isSuccess) _categories = result.data;
    notifyListeners();
  }

  Future<void> fetchGenres() async {
    final result = await _repository.getGenres();
    if (result.isSuccess) _genres = result.data;
    notifyListeners();
  }

  Future<void> fetchHomeSections() async {
    final result = await _repository.getHomeSections();
    if (result.isSuccess) _homeSections = result.data;
    notifyListeners();
  }

  // --- Bulk & Batch ---
  Future<void> bulkToggleStatus(List<String> ids, bool enable) async {
    for (var id in ids) {
      final category = _categories.firstWhere((c) => c.id == id);
      await updateCategory(category.copyWith(isEnabled: enable));
    }
  }

  Future<void> reorderCategories(List<String> ids) async {
    final result = await _repository.reorderCategories(ids);
    if (result.isSuccess) await fetchCategories();
  }

  Future<void> reorderHomeSections(List<String> ids) async {
    final result = await _repository.reorderHomeSections(ids);
    if (result.isSuccess) await fetchHomeSections();
  }

  // --- Content Sync Methods ---
  Future<void> addCategory(AdminCategoryEntity cat, {Uint8List? img, Uint8List? icon}) async {
    await _repository.addCategory(cat, image: img, icon: icon);
    await fetchCategories();
  }

  Future<void> updateCategory(AdminCategoryEntity cat, {Uint8List? img, Uint8List? icon}) async {
    await _repository.updateCategory(cat, image: img, icon: icon);
    await fetchCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _repository.deleteCategory(id);
    await fetchCategories();
  }

  Future<void> addGenre(GenreEntity genre, {Uint8List? image}) async {
    await _repository.addGenre(genre, image: image);
    await fetchGenres();
  }

  Future<void> updateGenre(GenreEntity genre, {Uint8List? image}) async {
    await _repository.updateGenre(genre, image: image);
    await fetchGenres();
  }

  Future<void> deleteGenre(String id) async {
    await _repository.deleteGenre(id);
    await fetchGenres();
  }

  Future<void> fetchLanguages() async {
    final result = await _repository.getLanguages();
    if (result.isSuccess) _languages = result.data;
    notifyListeners();
  }

  Future<void> addLanguage(LanguageEntity lang, {Uint8List? icon}) async {
    await _repository.addLanguage(lang, icon: icon);
    await fetchLanguages();
  }

  Future<void> deleteLanguage(String id) async {
    await _repository.deleteLanguage(id);
    await fetchLanguages();
  }

  Future<void> fetchCountries() async {
    final result = await _repository.getCountries();
    if (result.isSuccess) _countries = result.data;
    notifyListeners();
  }

  Future<void> addCountry(CountryEntity c, {Uint8List? flag}) async {
    await _repository.addCountry(c, flag: flag);
    await fetchCountries();
  }

  Future<void> deleteCountry(String id) async {
    await _repository.deleteCountry(id);
    await fetchCountries();
  }

  Future<void> fetchAgeRatings() async {
    final result = await _repository.getAgeRatings();
    if (result.isSuccess) _ageRatings = result.data;
    notifyListeners();
  }

  Future<void> addAgeRating(AgeRatingEntity r, {Uint8List? icon}) async {
    await _repository.addAgeRating(r, icon: icon);
    await fetchAgeRatings();
  }

  Future<void> deleteAgeRating(String id) async {
    await _repository.deleteAgeRating(id);
    await fetchAgeRatings();
  }

  Future<void> addHomeSection(HomeSectionEntity s, {Uint8List? banner}) async {
    await _repository.addHomeSection(s, banner: banner);
    await fetchHomeSections();
  }

  Future<void> updateHomeSection(HomeSectionEntity s, {Uint8List? banner}) async {
    await _repository.updateHomeSection(s, banner: banner);
    await fetchHomeSections();
  }

  Future<void> deleteHomeSection(String id) async {
    await _repository.deleteHomeSection(id);
    await fetchHomeSections();
  }
}
