import '../../../../core/utils/result.dart';
import '../entities/playback_progress_entity.dart';

abstract class PlayerProgressRepository {
  /// Saves or updates the playback progress for a specific movie.
  Future<Result<void>> saveProgress(PlaybackProgressEntity progress);

  /// Retrieves the playback progress for a specific movie.
  Future<Result<PlaybackProgressEntity?>> getProgress(String movieId);

  /// Fetches the list of movies currently in the "Continue Watching" state.
  Stream<List<PlaybackProgressEntity>> watchContinueWatching();

  /// Fetches the full watch history.
  Stream<List<PlaybackProgressEntity>> watchWatchHistory();

  /// Fetches all playback progress records.
  Future<Result<List<PlaybackProgressEntity>>> getAllProgress();

  /// Marks a movie as fully watched/completed.
  Future<Result<void>> markAsCompleted(String movieId);

  /// Removes a movie from the "Continue Watching" or "History" list.
  Future<Result<void>> deleteProgress(String movieId);
}
