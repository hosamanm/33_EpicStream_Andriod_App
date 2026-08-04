import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/video_source_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../services/player_service.dart';
import '../../../downloads/domain/repositories/download_repository.dart';
import '../../../downloads/domain/entities/download_item.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerService _playerService;
  final FirebaseAuth _auth;

  PlayerRepositoryImpl(this._playerService, this._auth);

  String get _userId => _auth.currentUser?.uid ?? '';

  @override
  Future<Result<VideoSourceEntity>> getVideoSource(String movieId, {bool isTrailer = false}) async {
    try {
      // 1. If not a trailer, check if a completed download exists for this movie
      if (!isTrailer) {
        final downloadRepo = sl<DownloadRepository>();
        final downloads = await downloadRepo.getDownloads();
        final downloadedItem = downloads.firstWhere(
          (e) => e.id == movieId && e.status == DownloadStatus.completed,
          orElse: () => const DownloadItem(id: '', title: '', posterUrl: '', localPath: '', remoteUrl: ''),
        );

        if (downloadedItem.id.isNotEmpty) {
          return Result.success(VideoSourceEntity(
            id: movieId,
            title: downloadedItem.title,
            url: downloadedItem.localPath,
            type: VideoType.mp4, // Downloads are saved as mp4
          ));
        }
      }

      // 2. Fallback to network source
      final model = await _playerService.getVideoSource(movieId, isTrailer: isTrailer);
      return Result.success(model);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> savePlaybackPosition(String movieId, Duration position, Duration totalDuration) async {
    try {
      if (_userId.isEmpty) return;
      await _playerService.updatePlaybackPosition(
        userId: _userId,
        movieId: movieId,
        positionSeconds: position.inSeconds,
        totalDurationSeconds: totalDuration.inSeconds,
      );
    } catch (e) {
      // Background failure - In a real app, you'd cache this locally if offline
      // and retry when connection is restored.
    }
  }

  @override
  Future<Duration> getPlaybackPosition(String movieId) async {
    try {
      if (_userId.isEmpty) return Duration.zero;
      final seconds = await _playerService.getPlaybackPosition(_userId, movieId);
      return Duration(seconds: seconds);
    } catch (e) {
      return Duration.zero;
    }
  }
}
