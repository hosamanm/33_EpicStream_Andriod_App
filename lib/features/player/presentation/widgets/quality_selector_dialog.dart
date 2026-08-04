import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/video_player_provider.dart';

/// A dialog to switch between different video qualities or enable Auto mode.
class QualitySelectorDialog extends StatelessWidget {
  const QualitySelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<VideoPlayerProvider>();
    final controller = playerProvider.betterPlayerController;

    if (controller == null) return const SizedBox.shrink();

    // Fetch available resolutions from the controller
    // This typically works for HLS/DASH streams where multiple bitrates are defined.
    final resolutions = controller.betterPlayerDataSource?.resolutions ?? {};
    final activeResolution = controller.betterPlayerDataSource?.url;

    return AlertDialog(
      title: const Text('Video Quality', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.darkSurface,
      content: resolutions.isEmpty
          ? const Text('Adaptive Bitrate (Auto) is active.', style: TextStyle(color: Colors.white70))
          : SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  // Auto Option
                  ListTile(
                    title: const Text('Auto', style: TextStyle(color: Colors.white)),
                    subtitle: const Text('Adjusts based on your connection', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    trailing: const Icon(Icons.check, color: AppColors.primaryRed), // Add logic for "Auto" selection
                    onTap: () {
                      // Logic to switch back to adaptive track
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(color: Colors.white12),
                  // Manual Resolutions
                  ...resolutions.entries.map((entry) {
                    final isSelected = entry.value == activeResolution;
                    return ListTile(
                      title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryRed) : null,
                      onTap: () {
                        controller.setResolution(entry.key);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: Colors.white60)),
        ),
      ],
    );
  }
}
