import '../../domain/entities/playback_progress_entity.dart';
import '../../domain/repositories/player_progress_repository.dart';

/// Service responsible for managing "Watch History" specific logic.
class WatchHistoryService {
  final PlayerProgressRepository _repository;

  WatchHistoryService(this._repository);

  /// Fetches the user's full watch history as a stream for real-time updates.
  Stream<List<PlaybackProgressEntity>> getWatchHistory() {
    return _repository.watchWatchHistory();
  }

  /// Clears a specific item from the history.
  Future<void> removeFromHistory(String movieId) async {
    await _repository.deleteProgress(movieId);
  }

  /// Clears all history (Implementation would depend on batch delete in Firestore).
  Future<void> clearAllHistory() async {
    // Logic for clearing all history
  }
}
