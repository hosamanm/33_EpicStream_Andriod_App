import '../../../movies/domain/entities/movie_entity.dart';
import '../../../movies/domain/repositories/movie_repository.dart';
import '../../domain/entities/playback_progress_entity.dart';
import '../../domain/repositories/player_progress_repository.dart';

/// Service responsible for managing "Continue Watching" specific logic.
/// Handles progress tracking and retrieving the list of partially watched content.
class ContinueWatchingService {
  final PlayerProgressRepository _progressRepository;
  final MovieRepository _movieRepository;

  ContinueWatchingService(this._progressRepository, this._movieRepository);

  /// Updates the user's progress for a movie.
  Future<void> updateProgress({
    required String movieId,
    required Duration position,
    required Duration totalDuration,
  }) async {
    final double percentage = position.inSeconds / totalDuration.inSeconds;
    final bool isCompleted = percentage > 0.95;

    final progress = PlaybackProgressEntity(
      movieId: movieId,
      lastPosition: position,
      totalDuration: totalDuration,
      percentage: percentage,
      lastPlayedTime: DateTime.now(),
      isCompleted: isCompleted,
    );

    await _progressRepository.saveProgress(progress);
  }

  /// Retrieves the list of movies currently in "Continue Watching".
  /// Filters out completed movies and fetches full movie details.
  Future<List<MovieEntity>> getContinueWatchingList() async {
    final result = await _progressRepository.getAllProgress();
    if (result.isError) return [];

    // Filter for non-completed movies and sort by last played
    final activeProgress = result.data
        .where((p) => !p.isCompleted)
        .toList()
      ..sort((a, b) => b.lastPlayedTime.compareTo(a.lastPlayedTime));

    final List<MovieEntity> movies = [];
    for (var progress in activeProgress.take(10)) {
      final movieResult = await _movieRepository.getMovieById(progress.movieId);
      if (movieResult.isSuccess && movieResult.data != null) {
        movies.add(movieResult.data!);
      }
    }
    return movies;
  }

  /// Retrieves the last position for a movie to resume playback.
  Future<Duration> getResumePosition(String movieId) async {
    final result = await _progressRepository.getProgress(movieId);
    if (result.isSuccess && result.data != null) {
      return result.data!.isCompleted ? Duration.zero : result.data!.lastPosition;
    }
    return Duration.zero;
  }
}
