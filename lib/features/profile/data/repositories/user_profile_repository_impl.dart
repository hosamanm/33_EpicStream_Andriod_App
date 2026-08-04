import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> createUserProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel(
        uid: profile.uid,
        displayName: profile.displayName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        photoUrl: profile.photoUrl,
        role: profile.role,
        status: profile.status,
        language: profile.language,
        country: profile.country,
        favoriteGenres: profile.favoriteGenres,
        themeMode: profile.themeMode,
        notificationEnabled: profile.notificationEnabled,
        subtitleEnabled: profile.subtitleEnabled,
        audioLanguage: profile.audioLanguage,
        watchHistoryEnabled: profile.watchHistoryEnabled,
        downloadEnabled: profile.downloadEnabled,
        isGuest: profile.isGuest,
        isEmailVerified: profile.isEmailVerified,
        fcmToken: profile.fcmToken,
        deviceInfo: profile.deviceInfo,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
        lastLogin: profile.lastLogin,
      );
      await _remoteDataSource.createUserProfile(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfileEntity?>> getUserProfile(String uid) async {
    try {
      final profile = await _remoteDataSource.getUserProfile(uid);
      return Result.success(profile);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel(
        uid: profile.uid,
        displayName: profile.displayName,
        email: profile.email,
        phoneNumber: profile.phoneNumber,
        photoUrl: profile.photoUrl,
        role: profile.role,
        status: profile.status,
        language: profile.language,
        country: profile.country,
        favoriteGenres: profile.favoriteGenres,
        themeMode: profile.themeMode,
        notificationEnabled: profile.notificationEnabled,
        subtitleEnabled: profile.subtitleEnabled,
        audioLanguage: profile.audioLanguage,
        watchHistoryEnabled: profile.watchHistoryEnabled,
        downloadEnabled: profile.downloadEnabled,
        isGuest: profile.isGuest,
        isEmailVerified: profile.isEmailVerified,
        fcmToken: profile.fcmToken,
        deviceInfo: profile.deviceInfo,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(), // Always update the timestamp on update
        lastLogin: profile.lastLogin,
      );
      await _remoteDataSource.updateUserProfile(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUserProfile(String uid) async {
    try {
      await _remoteDataSource.deleteUserProfile(uid);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserProfileEntity?> watchUserProfile(String uid) {
    return _remoteDataSource.watchUserProfile(uid);
  }
}
