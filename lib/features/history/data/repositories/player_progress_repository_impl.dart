import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/playback_progress_entity.dart';
import '../../domain/repositories/player_progress_repository.dart';
import '../datasources/playback_progress_remote_datasource.dart';
import '../models/playback_progress_model.dart';

class PlayerProgressRepositoryImpl implements PlayerProgressRepository {
  final PlaybackProgressRemoteDataSource _remoteDataSource;
  final FirebaseAuth _auth;

  PlayerProgressRepositoryImpl(this._remoteDataSource, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<void>> saveProgress(PlaybackProgressEntity progress) async {
    try {
      if (_userId.isEmpty) return Result.failure(const ServerFailure('User not authenticated'));
      final model = PlaybackProgressModel(
        movieId: progress.movieId,
        lastPosition: progress.lastPosition,
        totalDuration: progress.totalDuration,
        percentage: progress.percentage,
        lastPlayedTime: progress.lastPlayedTime,
        isCompleted: progress.isCompleted,
      );
      await _remoteDataSource.saveProgress(_userId, model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<PlaybackProgressEntity?>> getProgress(String movieId) async {
    try {
      if (_userId.isEmpty) return const Result.success(null);
      final progress = await _remoteDataSource.getProgress(_userId, movieId);
      return Result.success(progress);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<PlaybackProgressEntity>>> getAllProgress() async {
    try {
      if (_userId.isEmpty) return const Result.success([]);
      final results = await _remoteDataSource.getAllProgress(_userId);
      return Result.success(results);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<PlaybackProgressEntity>> watchContinueWatching() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _remoteDataSource.watchContinueWatching(user.uid);
    });
  }

  @override
  Stream<List<PlaybackProgressEntity>> watchWatchHistory() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _remoteDataSource.watchWatchHistory(user.uid);
    });
  }

  @override
  Future<Result<void>> markAsCompleted(String movieId) async {
    try {
      if (_userId.isEmpty) return Result.failure(const ServerFailure('User not authenticated'));
      final current = await _remoteDataSource.getProgress(_userId, movieId);
      if (current != null) {
        final updated = PlaybackProgressModel(
          movieId: current.movieId,
          lastPosition: current.totalDuration,
          totalDuration: current.totalDuration,
          percentage: 1.0,
          lastPlayedTime: DateTime.now(),
          isCompleted: true,
        );
        await _remoteDataSource.saveProgress(_userId, updated);
      }
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteProgress(String movieId) async {
    try {
      if (_userId.isEmpty) return Result.failure(const ServerFailure('User not authenticated'));
      await _remoteDataSource.deleteProgress(_userId, movieId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
