import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/notification_history_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_settings_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  NotificationRepositoryImpl(this._remoteDataSource, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  @override
  Stream<List<NotificationHistoryEntity>> watchNotificationHistory() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _remoteDataSource.watchNotificationHistory(user.uid);
    });
  }

  @override
  Future<Result<void>> markAsRead(String historyId) async {
    try {
      await _remoteDataSource.markAsRead(historyId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    try {
      final uid = _userId;
      if (uid == null) return Result.failure(const ServerFailure('User not authenticated'));
      await _remoteDataSource.markAllAsRead(uid);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String historyId) async {
    try {
      await _remoteDataSource.deleteNotification(historyId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    try {
      final uid = _userId;
      if (uid == null) return const Result.success(0);
      final count = await _remoteDataSource.getUnreadCount(uid);
      return Result.success(count);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateFcmToken(String token) async {
    try {
      final uid = _userId;
      if (uid == null) return const Result.success(null);
      await _remoteDataSource.updateFcmToken(uid, token);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateNotificationSettings({
    required bool enabled,
    bool? marketingEnabled,
    List<String>? genrePreferences,
  }) async {
    try {
      final uid = _userId;
      if (uid == null) return Result.failure(const ServerFailure('User not authenticated'));
      
      final currentSettings = await _remoteDataSource.getNotificationSettings(uid);
      
      final updatedModel = NotificationSettingsModel(
        userId: uid,
        notificationsEnabled: enabled,
        marketingEnabled: marketingEnabled ?? currentSettings?.marketingEnabled ?? true,
        genrePreferences: genrePreferences ?? currentSettings?.genrePreferences ?? [],
        languagePreferences: currentSettings?.languagePreferences ?? ['en'],
      );

      await _remoteDataSource.updateNotificationSettings(updatedModel);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
