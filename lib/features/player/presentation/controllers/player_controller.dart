import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import '../providers/video_player_provider.dart';
import '../providers/player_state.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/entities/video_source_entity.dart';

/// The Business Logic Controller for the Video Player.
/// It coordinates between the UI (Provider) and the Data (Repository).
class PlayerModuleController {
  final VideoPlayerProvider _provider;
  final PlayerRepository _repository;
  Timer? _progressTimer;

  PlayerModuleController({
    required VideoPlayerProvider provider,
    required PlayerRepository repository,
  })  : _provider = provider,
        _repository = repository;

  /// Loads the video source and prepares the player.
  Future<void> loadAndPlayVideo(String movieId, {bool isTrailer = false}) async {
    _provider.setState(PlayerLoading());

    final result = await _repository.getVideoSource(movieId, isTrailer: isTrailer);
    
    if (result.isSuccess) {
      final source = result.data;
      
      // Trailers usually don't need resume logic
      final savedPosition = isTrailer ? Duration.zero : await _repository.getPlaybackPosition(movieId);
      
      _provider.initializePlayer(source, startAt: savedPosition);
      
      if (!isTrailer) {
        _startProgressSync(movieId);
      }
    } else {
      _provider.setState(PlayerError(result.failure.message));
    }
  }

  /// Syncs the current playback position with the server every 20 seconds.
  void _startProgressSync(String movieId) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 20), (timer) async {
      final controller = _provider.betterPlayerController;
      if (controller != null && controller.isPlaying() == true) {
        final currentPosition = controller.videoPlayerController?.value.position;
        final totalDuration = controller.videoPlayerController?.value.duration;
        
        if (currentPosition != null && totalDuration != null) {
          await _repository.savePlaybackPosition(movieId, currentPosition, totalDuration);
        }
      }
    });
  }

  void retry(String movieId, {bool isTrailer = false}) {
    loadAndPlayVideo(movieId, isTrailer: isTrailer);
  }

  void dispose() {
    _progressTimer?.cancel();
  }
}
