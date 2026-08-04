import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../movies/data/services/firebase_storage_service.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../../domain/entities/language_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/age_rating_entity.dart';
import '../../domain/entities/home_section_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/admin_category_model.dart';
import '../models/genre_model.dart';
import '../models/language_model.dart';
import '../models/country_model.dart';
import '../models/age_rating_model.dart';
import '../models/home_section_model.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;
  final ActivityLogRepository _logRepository;
  final FirebaseAuth _auth;

  CategoryRepositoryImpl(this._firestore, this._storageService, this._logRepository, this._auth);

  String get _adminEmail => _auth.currentUser?.email ?? 'system';
  String get _adminId => _auth.currentUser?.uid ?? 'system';

  @override
  Future<Result<List<AdminCategoryEntity>>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => AdminCategoryModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addCategory(AdminCategoryEntity category, {Uint8List? image, Uint8List? icon}) async {
    try {
      final docRef = _firestore.collection('categories').doc();
      String? imageUrl = category.imageUrl;
      String? iconUrl = category.iconUrl;

      if (image != null) {
        imageUrl = await _storageService.uploadFile(path: 'category_images/${docRef.id}.jpg', file: image, onProgress: (_) {});
      }
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'category_icons/${docRef.id}.png', file: icon, onProgress: (_) {});
      }

      final model = AdminCategoryModel(
        id: docRef.id,
        name: category.name,
        description: category.description,
        imageUrl: imageUrl,
        iconUrl: iconUrl,
        displayOrder: category.displayOrder,
        isEnabled: category.isEnabled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, docRef.id, 'Added category: ${category.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateCategory(AdminCategoryEntity category, {Uint8List? image, Uint8List? icon}) async {
    try {
      String? imageUrl = category.imageUrl;
      String? iconUrl = category.iconUrl;

      if (image != null) {
        imageUrl = await _storageService.uploadFile(path: 'category_images/${category.id}.jpg', file: image, onProgress: (_) {});
      }
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'category_icons/${category.id}.png', file: icon, onProgress: (_) {});
      }

      final model = AdminCategoryModel(
        id: category.id,
        name: category.name,
        description: category.description,
        imageUrl: imageUrl,
        iconUrl: iconUrl,
        displayOrder: category.displayOrder,
        isEnabled: category.isEnabled,
        createdAt: category.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('categories').doc(category.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, category.id, 'Updated category: ${category.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted category');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorderCategories(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < ids.length; i++) {
        batch.update(_firestore.collection('categories').doc(ids[i]), {'displayOrder': i});
      }
      await batch.commit();
      await _logAction(ActivityAction.edit, ActivityModule.categories, 'batch', 'Reordered categories');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<GenreEntity>>> getGenres() async {
    try {
      final snapshot = await _firestore.collection('genres').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => GenreModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addGenre(GenreEntity genre, {Uint8List? image}) async {
    try {
      final docRef = _firestore.collection('genres').doc();
      String? imageUrl = genre.imageUrl;
      if (image != null) {
        imageUrl = await _storageService.uploadFile(path: 'genre_images/${docRef.id}.jpg', file: image, onProgress: (_) {});
      }
      final model = GenreModel(
        id: docRef.id,
        name: genre.name,
        imageUrl: imageUrl,
        isEnabled: genre.isEnabled,
        displayOrder: genre.displayOrder,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, docRef.id, 'Added genre: ${genre.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateGenre(GenreEntity genre, {Uint8List? image}) async {
    try {
      String? imageUrl = genre.imageUrl;
      if (image != null) {
        imageUrl = await _storageService.uploadFile(path: 'genre_images/${genre.id}.jpg', file: image, onProgress: (_) {});
      }
      final model = GenreModel(
        id: genre.id,
        name: genre.name,
        imageUrl: imageUrl,
        isEnabled: genre.isEnabled,
        displayOrder: genre.displayOrder,
        createdAt: genre.createdAt,
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('genres').doc(genre.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, genre.id, 'Updated genre: ${genre.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteGenre(String id) async {
    try {
      await _firestore.collection('genres').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted genre');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LanguageEntity>>> getLanguages() async {
    try {
      final snapshot = await _firestore.collection('languages').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => LanguageModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addLanguage(LanguageEntity language, {Uint8List? icon}) async {
    try {
      String? iconUrl = language.iconUrl;
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'language_icons/${language.code}.png', file: icon, onProgress: (_) {});
      }
      final model = LanguageModel(
        id: language.code,
        name: language.name,
        code: language.code,
        iconUrl: iconUrl,
        isDefault: language.isDefault,
        isEnabled: language.isEnabled,
        displayOrder: language.displayOrder,
      );
      await _firestore.collection('languages').doc(language.code).set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, language.code, 'Added language: ${language.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateLanguage(LanguageEntity language, {Uint8List? icon}) async {
    try {
      String? iconUrl = language.iconUrl;
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'language_icons/${language.id}.png', file: icon, onProgress: (_) {});
      }
      final model = LanguageModel(
        id: language.id,
        name: language.name,
        code: language.code,
        iconUrl: iconUrl,
        isDefault: language.isDefault,
        isEnabled: language.isEnabled,
        displayOrder: language.displayOrder,
      );
      await _firestore.collection('languages').doc(language.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, language.id, 'Updated language: ${language.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteLanguage(String id) async {
    try {
      await _firestore.collection('languages').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted language');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CountryEntity>>> getCountries() async {
    try {
      final snapshot = await _firestore.collection('countries').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => CountryModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addCountry(CountryEntity country, {Uint8List? flag}) async {
    try {
      String? flagUrl = country.flagUrl;
      if (flag != null) {
        flagUrl = await _storageService.uploadFile(path: 'country_flags/${country.code}.png', file: flag, onProgress: (_) {});
      }
      final model = CountryModel(
        id: country.code,
        name: country.name,
        code: country.code,
        flagUrl: flagUrl,
        displayOrder: country.displayOrder,
        isEnabled: country.isEnabled,
      );
      await _firestore.collection('countries').doc(country.code).set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, country.code, 'Added country: ${country.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateCountry(CountryEntity country, {Uint8List? flag}) async {
    try {
      String? flagUrl = country.flagUrl;
      if (flag != null) {
        flagUrl = await _storageService.uploadFile(path: 'country_flags/${country.id}.png', file: flag, onProgress: (_) {});
      }
      final model = CountryModel(
        id: country.id,
        name: country.name,
        code: country.code,
        flagUrl: flagUrl,
        displayOrder: country.displayOrder,
        isEnabled: country.isEnabled,
      );
      await _firestore.collection('countries').doc(country.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, country.id, 'Updated country: ${country.name}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteCountry(String id) async {
    try {
      await _firestore.collection('countries').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted country');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AgeRatingEntity>>> getAgeRatings() async {
    try {
      final snapshot = await _firestore.collection('age_ratings').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => AgeRatingModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addAgeRating(AgeRatingEntity rating, {Uint8List? icon}) async {
    try {
      final docRef = _firestore.collection('age_ratings').doc();
      String? iconUrl = rating.iconUrl;
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'age_rating_icons/${docRef.id}.png', file: icon, onProgress: (_) {});
      }
      final model = AgeRatingModel(
        id: docRef.id,
        rating: rating.rating,
        description: rating.description,
        iconUrl: iconUrl,
        displayOrder: rating.displayOrder,
      );
      await docRef.set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, docRef.id, 'Added age rating: ${rating.rating}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateAgeRating(AgeRatingEntity rating, {Uint8List? icon}) async {
    try {
      String? iconUrl = rating.iconUrl;
      if (icon != null) {
        iconUrl = await _storageService.uploadFile(path: 'age_rating_icons/${rating.id}.png', file: icon, onProgress: (_) {});
      }
      final model = AgeRatingModel(
        id: rating.id,
        rating: rating.rating,
        description: rating.description,
        iconUrl: iconUrl,
        displayOrder: rating.displayOrder,
      );
      await _firestore.collection('age_ratings').doc(rating.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, rating.id, 'Updated age rating: ${rating.rating}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAgeRating(String id) async {
    try {
      await _firestore.collection('age_ratings').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted age rating');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<HomeSectionEntity>>> getHomeSections() async {
    try {
      final snapshot = await _firestore.collection('home_sections').orderBy('displayOrder').get();
      return Result.success(snapshot.docs.map((doc) => HomeSectionModel.fromFirestore(doc)).toList());
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addHomeSection(HomeSectionEntity section, {Uint8List? banner}) async {
    try {
      final docRef = _firestore.collection('home_sections').doc();
      final model = HomeSectionModel(
        id: docRef.id,
        title: section.title,
        type: section.type,
        displayOrder: section.displayOrder,
        isEnabled: section.isEnabled,
        queryType: section.queryType,
        customQueryId: section.customQueryId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(model.toFirestore());
      await _logAction(ActivityAction.edit, ActivityModule.categories, docRef.id, 'Added home section: ${section.title}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateHomeSection(HomeSectionEntity section, {Uint8List? banner}) async {
    try {
      final model = HomeSectionModel(
        id: section.id,
        title: section.title,
        type: section.type,
        displayOrder: section.displayOrder,
        isEnabled: section.isEnabled,
        queryType: section.queryType,
        customQueryId: section.customQueryId,
        createdAt: section.createdAt,
        updatedAt: DateTime.now(),
      );
      await _firestore.collection('home_sections').doc(section.id).set(model.toFirestore(), SetOptions(merge: true));
      await _logAction(ActivityAction.edit, ActivityModule.categories, section.id, 'Updated home section: ${section.title}');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteHomeSection(String id) async {
    try {
      await _firestore.collection('home_sections').doc(id).delete();
      await _logAction(ActivityAction.delete, ActivityModule.categories, id, 'Deleted home section');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorderHomeSections(List<String> ids) async {
    try {
      final batch = _firestore.batch();
      for (int i = 0; i < ids.length; i++) {
        batch.update(_firestore.collection('home_sections').doc(ids[i]), {'displayOrder': i});
      }
      await batch.commit();
      await _logAction(ActivityAction.edit, ActivityModule.categories, 'batch', 'Reordered home sections');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  Future<void> _logAction(ActivityAction action, ActivityModule module, String targetId, String description) async {
    await _logRepository.logAction(ActivityLogEntity(
      id: '',
      adminId: _adminId,
      adminEmail: _adminEmail,
      action: action,
      module: module,
      targetId: targetId,
      description: description,
      ipAddress: '0.0.0.0',
      timestamp: DateTime.now(),
    ));
  }
}
