import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/repositories/category_repository.dart';

enum CategoriesViewType { grid, list }

class CategoriesProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoriesProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryEntity> _categories = [];
  List<CategoryEntity> get categories => _categories;

  List<GenreEntity> _genres = [];
  List<GenreEntity> get genres => _genres;

  CategoriesViewType _viewType = CategoriesViewType.grid;
  CategoriesViewType get viewType => _viewType;

  String _selectedSort = 'Popular';
  String get selectedSort => _selectedSort;

  // Filter Options (Master Lists)
  final List<String> languages = ['English', 'Spanish', 'French', 'Hindi', 'Japanese', 'Korean'];
  final List<String> countries = ['USA', 'UK', 'Spain', 'India', 'Japan', 'Korea', 'France'];
  final List<String> years = List.generate(24, (index) => (2024 - index).toString());

  // Selected Filters
  String? selectedLanguage;
  String? selectedCountry;
  String? selectedYear;
  double minRating = 0;
  String? selectedGenreId;

  void setViewType(CategoriesViewType type) {
    _viewType = type;
    notifyListeners();
  }

  void setSort(String sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void selectGenre(String? genreId) {
    selectedGenreId = genreId;
    notifyListeners();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getGenres(),
      ]);

      _categories = results[0] as List<CategoryEntity>;
      _genres = results[1] as List<GenreEntity>;
    } catch (e) {
      debugPrint('Error loading categories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetFilters() {
    selectedLanguage = null;
    selectedCountry = null;
    selectedYear = null;
    minRating = 0;
    selectedGenreId = null;
    notifyListeners();
  }

  void updateRating(double val) {
    minRating = val;
    notifyListeners();
  }

  void applyFilters() {
    // This will trigger searches in linked screens
    notifyListeners();
  }
}
