import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/video_player_provider.dart';

/// A dialog to customize subtitle appearance and synchronization.
class SubtitleSettingsDialog extends StatelessWidget {
  const SubtitleSettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = context.watch<VideoPlayerProvider>();
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Subtitle Settings', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.darkSurface,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font Size
            const Text('Font Size', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Slider(
              value: 16.0, // Should be from a settings state
              min: 10,
              max: 30,
              divisions: 4,
              label: 'Size',
              activeColor: AppColors.primaryRed,
              onChanged: (val) {
                // Update subtitle style in better_player
              },
            ),
            const SizedBox(height: AppDimensions.m),

            // Text Color
            const Text('Text Color', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const Row(
              children: [
                _ColorOption(color: Colors.white, isSelected: true),
                _ColorOption(color: Colors.yellow),
                _ColorOption(color: Colors.cyan),
              ],
            ),
            const SizedBox(height: AppDimensions.m),

            // Delay
            const Text('Subtitle Delay (Seconds)', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                  onPressed: () {},
                ),
                const Text('0.0s', style: TextStyle(color: Colors.white)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE', style: TextStyle(color: AppColors.primaryRed)),
        ),
      ],
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const _ColorOption({required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8),
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: AppColors.primaryRed, width: 2) : null,
      ),
    );
  }
}
