import '../../../../core/utils/result.dart';
import '../entities/video_source_entity.dart';

abstract class PlayerRepository {
  Future<Result<VideoSourceEntity>> getVideoSource(String movieId, {bool isTrailer = false});
  Future<void> savePlaybackPosition(String movieId, Duration position, Duration totalDuration);
  Future<Duration> getPlaybackPosition(String movieId);
}
