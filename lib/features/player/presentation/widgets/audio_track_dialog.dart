import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/video_player_provider.dart';

/// A dialog to switch between different audio tracks (languages).
class AudioTrackDialog extends StatelessWidget {
  const AudioTrackDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<VideoPlayerProvider>();
    final controller = playerProvider.betterPlayerController;
    
    if (controller == null) return const SizedBox.shrink();

    // Fetch available audio tracks from the controller
    // In BetterPlayer, ASMS (HLS/DASH) audio tracks are accessed via betterPlayerAsmsAudioTracks
    final tracks = controller.betterPlayerAsmsAudioTracks ?? [];

    return AlertDialog(
      title: const Text('Audio Language', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.darkSurface,
      content: tracks.isEmpty 
        ? const Text('No alternative audio tracks available.', style: TextStyle(color: Colors.white70))
        : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                // Check if this is the active track
                return ListTile(
                  title: Text(track.language ?? 'Track ${index + 1}', style: const TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.check, color: AppColors.primaryRed), // Add selection logic if needed
                  onTap: () {
                    // Correct method to switch audio tracks in BetterPlayer
                    controller.setAudioTrack(track);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }
}
