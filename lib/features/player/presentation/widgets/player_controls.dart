import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'seek_bar.dart';
import 'volume_overlay.dart';
import 'brightness_overlay.dart';
import 'playback_speed_dialog.dart';
import 'fullscreen_button.dart';
import 'quality_selector_dialog.dart';
import 'audio_track_dialog.dart';
import 'subtitle_settings_dialog.dart';

/// The main overlay for video player controls.
/// Handles visibility, gestures for volume/brightness, and playback actions.
class PlayerControls extends StatefulWidget {
  final BetterPlayerController controller;
  final String title;
  final VoidCallback onToggleFullScreen;

  const PlayerControls({
    super.key,
    required this.controller,
    required this.title,
    required this.onToggleFullScreen,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _visible = true;
  Timer? _hideTimer;

  double _volume = 0.5;
  double _brightness = 0.5;
  bool _showVolumeOverlay = false;
  bool _showBrightnessOverlay = false;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
    // Initialize volume from controller
    _volume = widget.controller.videoPlayerController?.value.volume ?? 0.5;
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
  }

  void _toggleVisibility() {
    setState(() {
      _visible = !_visible;
      if (_visible) _startHideTimer();
    });
  }

  void _handleBack(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Exit Player?', style: TextStyle(color: Colors.white)),
        content: const Text('Do you want to stop watching?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CONTINUE', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Exit player
            },
            child: const Text('EXIT', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu(BuildContext context) {
    _hideTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.high_quality, color: Colors.white),
              title: const Text('Video Quality', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => const QualitySelectorDialog());
              },
            ),
            ListTile(
              leading: const Icon(Icons.subtitles, color: Colors.white),
              title: const Text('Subtitles & Captions', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => const SubtitleSettingsDialog());
              },
            ),
            ListTile(
              leading: const Icon(Icons.audiotrack, color: Colors.white),
              title: const Text('Audio Language', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                showDialog(context: context, builder: (_) => const AudioTrackDialog());
              },
            ),
          ],
        ),
      ),
    ).then((_) => _startHideTimer());
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoController = widget.controller.videoPlayerController;

    return GestureDetector(
      onTap: _toggleVisibility,
      onVerticalDragUpdate: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < screenWidth / 2) {
          // Left side: Brightness
          setState(() {
            _showBrightnessOverlay = true;
            _showVolumeOverlay = false;
            _brightness = (_brightness - details.delta.dy / 200).clamp(0.0, 1.0);
          });
        } else {
          // Right side: Volume
          setState(() {
            _showVolumeOverlay = true;
            _showBrightnessOverlay = false;
            _volume = (_volume - details.delta.dy / 200).clamp(0.0, 1.0);
            widget.controller.setVolume(_volume);
          });
        }
      },
      onVerticalDragEnd: (_) {
        setState(() {
          _showVolumeOverlay = false;
          _showBrightnessOverlay = false;
        });
      },
      child: Stack(
        children: [
          // 1. Shadow Overlay for visibility
          AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(color: Colors.black45),
          ),

          // 2. Center Controls (Play/Pause/Skip)
          if (_visible)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, size: 48, color: Colors.white),
                    onPressed: () {
                      final current = videoController?.value.position ?? Duration.zero;
                      widget.controller.seekTo(current - const Duration(seconds: 10));
                      _startHideTimer();
                    },
                  ),
                  const SizedBox(width: 32),
                  _buildPlayPauseButton(),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, size: 48, color: Colors.white),
                    onPressed: () {
                      final current = videoController?.value.position ?? Duration.zero;
                      widget.controller.seekTo(current + const Duration(seconds: 10));
                      _startHideTimer();
                    },
                  ),
                ],
              ),
            ),

          // 3. Top Bar (Title & Settings)
          if (_visible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => _handleBack(context),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.speed_rounded, color: Colors.white),
                        onPressed: () => _showPlaybackSpeedDialog(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => _showSettingsMenu(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Bottom Bar (Seek Bar & Fullscreen)
          if (_visible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (videoController != null)
                      ValueListenableBuilder(
                        valueListenable: videoController,
                        builder: (context, value, child) {
                          return PlayerSeekBar(
                            position: value.position,
                            duration: value.duration ?? Duration.zero,
                            onSeek: (duration) => widget.controller.seekTo(duration),
                            onSeekStart: () => _hideTimer?.cancel(),
                            onSeekEnd: _startHideTimer,
                          );
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(_volume == 0 ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    _volume = _volume == 0 ? 0.5 : 0;
                                    widget.controller.setVolume(_volume);
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              const Text('AUTO-PLAY', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          FullscreenButton(
                            isFullscreen: widget.controller.isFullScreen,
                            onToggle: widget.onToggleFullScreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Volume/Brightness Overlays
          if (_showVolumeOverlay)
            Center(child: VolumeOverlay(volume: _volume)),
          if (_showBrightnessOverlay)
            Center(child: BrightnessOverlay(brightness: _brightness)),

          // 6. Buffering Indicator handled by VideoPlayerWidget or overlay
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    final videoController = widget.controller.videoPlayerController;
    if (videoController == null) return const SizedBox.shrink();

    return ValueListenableBuilder(
      valueListenable: videoController,
      builder: (context, value, child) {
        final isPlaying = value.isPlaying;
        return IconButton(
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
            size: 80,
            color: Colors.white,
          ),
          onPressed: () {
            if (isPlaying) {
              widget.controller.pause();
            } else {
              widget.controller.play();
            }
            _startHideTimer();
          },
        );
      },
    );
  }

  void _showPlaybackSpeedDialog(BuildContext context) {
    _hideTimer?.cancel();
    final videoController = widget.controller.videoPlayerController;
    if (videoController == null) return;

    double currentSpeed = 1.0;
    try {
      // Use dynamic to access playbackSpeed if it's missing from the type definition
      currentSpeed = (videoController.value as dynamic).playbackSpeed ?? 1.0;
    } catch (_) {
      currentSpeed = 1.0;
    }

    showDialog(
      context: context,
      builder: (_) => PlaybackSpeedDialog(
        currentSpeed: currentSpeed,
        onSpeedSelected: (speed) => widget.controller.setSpeed(speed),
      ),
    ).then((_) => _startHideTimer());
  }
}
