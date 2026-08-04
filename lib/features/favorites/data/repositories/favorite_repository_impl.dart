import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  FavoriteRepositoryImpl(this._remoteDataSource, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<void>> addFavorite(FavoriteEntity favorite) async {
    try {
      if (_userId.isEmpty) return Result.failure(const ServerFailure('User not authenticated'));
      await _remoteDataSource.addFavorite(_userId, FavoriteModel.fromEntity(favorite, _userId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removeFavorite(String id) async {
    try {
      if (_userId.isEmpty) return Result.failure(const ServerFailure('User not authenticated'));
      await _remoteDataSource.removeFavorite(_userId, id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<FavoriteEntity>> watchFavorites({String? type}) {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _remoteDataSource.watchFavorites(user.uid, type: type);
    });
  }

  @override
  Future<Result<bool>> isFavorite(String id) async {
    try {
      if (_userId.isEmpty) return Result.success(false);
      final exists = await _remoteDataSource.isFavorite(_userId, id);
      return Result.success(exists);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
