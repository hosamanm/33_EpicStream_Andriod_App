import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/video_source_entity.dart';
import 'player_state.dart';

/// Provider to manage the Video Player's lifecycle and UI state.
/// It interacts with the BetterPlayerController and exposes state to the UI.
class VideoPlayerProvider extends ChangeNotifier {
  BetterPlayerController? _betterPlayerController;
  VideoPlayerState _state = PlayerInitial();

  BetterPlayerController? get betterPlayerController => _betterPlayerController;
  VideoPlayerState get state => _state;

  void setState(VideoPlayerState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Initializes the Better Player with the provided video source.
  /// Supports both network and local file sources.
  void initializePlayer(VideoSourceEntity source, {Duration startAt = Duration.zero}) {
    setState(PlayerLoading());

    // Check if source URL is a local file path
    final bool isLocal = source.url.startsWith('/') || source.url.startsWith('file://');

    final dataSource = BetterPlayerDataSource(
      isLocal ? BetterPlayerDataSourceType.file : BetterPlayerDataSourceType.network,
      source.url,
      videoFormat: source.type == VideoType.hls ? BetterPlayerVideoFormat.hls : null,
      subtitles: source.subtitleUrl != null
          ? [
              BetterPlayerSubtitlesSource(
                type: isLocal ? BetterPlayerSubtitlesSourceType.file : BetterPlayerSubtitlesSourceType.network,
                urls: [source.subtitleUrl!],
              ),
            ]
          : null,
      headers: source.headers,
    );

    final configuration = BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      fullScreenByDefault: true,
      allowedScreenSleep: false,
      startAt: startAt,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      handleLifecycle: true,
      autoDetectFullscreenDeviceOrientation: true,
      errorBuilder: (context, errorMessage) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 42),
            const SizedBox(height: 16),
            Text(errorMessage ?? 'Video Playback Error', style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );

    _betterPlayerController = BetterPlayerController(configuration);
    _betterPlayerController!.setupDataSource(dataSource).then((_) {
      setState(PlayerReady(source));
    }).catchError((error) {
      setState(PlayerError(error.toString()));
    });

    _betterPlayerController!.addEventsListener((event) {
      if (event.betterPlayerEventType == BetterPlayerEventType.bufferingStart) {
        setState(PlayerBuffering());
      } else if (event.betterPlayerEventType == BetterPlayerEventType.bufferingEnd) {
        setState(PlayerReady(source));
      }
    });
  }

  @override
  void dispose() {
    _betterPlayerController?.dispose();
    super.dispose();
  }
}
