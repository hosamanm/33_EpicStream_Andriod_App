import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/playback_progress_entity.dart';

class ContinueWatchingCard extends StatelessWidget {
  final PlaybackProgressEntity progress;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  const ContinueWatchingCard({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.s),
        ),
        child: Row(
          children: [
            // Thumbnail with Progress Bar
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppDimensions.s)),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: Colors.white10,
                      child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white70)),
                    ),
                  ),
                ),
                Container(
                  height: 4,
                  width: 177, // Matches 100 height * 16/9
                  color: Colors.white24,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.percentage.clamp(0.0, 1.0),
                    child: Container(color: AppColors.primaryRed),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Movie ID: ${progress.movieId}', // In production, resolve this to Movie title
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${progress.lastPosition.inMinutes}m left',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white70),
              onPressed: onInfo,
            ),
          ],
        ),
      ),
    );
  }
}
