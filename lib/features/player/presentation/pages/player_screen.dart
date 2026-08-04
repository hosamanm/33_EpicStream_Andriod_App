import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/video_player_widget.dart';

/// The main entry point for the Video Player.
/// It handles full-screen orientation and system UI visibility.
class PlayerScreen extends StatefulWidget {
  final String movieId;
  final bool isTrailer;

  const PlayerScreen({
    super.key, 
    required this.movieId,
    this.isTrailer = false,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Force landscape orientation for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Reset orientations and system UI when leaving the player
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: VideoPlayerWidget(
        movieId: widget.movieId,
        isTrailer: widget.isTrailer,
      ),
    );
  }
}
