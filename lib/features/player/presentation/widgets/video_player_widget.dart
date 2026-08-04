import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/video_player_provider.dart';
import '../providers/player_state.dart';
import '../controllers/player_controller.dart';
import 'player_controls.dart';

/// A production-grade reusable Video Player Widget.
/// It integrates the BetterPlayer engine with custom cinematic controls.
class VideoPlayerWidget extends StatefulWidget {
  final String movieId;
  final bool isTrailer;

  const VideoPlayerWidget({
    super.key, 
    required this.movieId,
    this.isTrailer = false,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late PlayerModuleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PlayerModuleController(
      provider: context.read<VideoPlayerProvider>(),
      repository: context.read(), 
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadAndPlayVideo(widget.movieId, isTrailer: widget.isTrailer);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VideoPlayerProvider>().state;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _buildPlayerContent(state),
      ),
    );
  }

  Widget _buildPlayerContent(VideoPlayerState state) {
    if (state is PlayerLoading) {
      return const _PlayerLoadingView();
    }

    if (state is PlayerError) {
      return AppErrorView(
        message: state.message,
        onRetry: () => _controller.retry(widget.movieId, isTrailer: widget.isTrailer),
      );
    }

    if (state is PlayerReady || state is PlayerBuffering) {
      final playerProvider = context.read<VideoPlayerProvider>();
      final betterController = playerProvider.betterPlayerController;
      
      if (betterController != null) {
        return Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: betterController),
            ),
            // Custom cinematic controls overlay
            PlayerControls(
              controller: betterController,
              title: state is PlayerReady ? state.source.title : 'Loading...',
              onToggleFullScreen: () => betterController.toggleFullScreen(),
            ),
            // Centered buffering indicator for mid-stream loading
            if (state is PlayerBuffering)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              ),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }
}

class _PlayerLoadingView extends StatelessWidget {
  const _PlayerLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
        ),
        SizedBox(height: AppDimensions.m),
        Text(
          'Preparing cinematic experience...',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
