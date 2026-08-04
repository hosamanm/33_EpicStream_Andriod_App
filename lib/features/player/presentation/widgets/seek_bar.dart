import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A custom seek bar for the OTT player.
/// Displays current position, remaining time, and allows seeking.
class PlayerSeekBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onSeek;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;

  const PlayerSeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onSeek,
    this.onSeekStart,
    this.onSeekEnd,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = duration - position;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.primaryRed,
            inactiveTrackColor: Colors.white24,
            thumbColor: AppColors.primaryRed,
          ),
          child: Slider(
            value: position.inSeconds.toDouble(),
            min: 0,
            max: duration.inSeconds.toDouble(),
            onChanged: (value) {
              onSeek?.call(Duration(seconds: value.toInt()));
            },
            onChangeStart: (_) => onSeekStart?.call(),
            onChangeEnd: (_) => onSeekEnd?.call(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Text(
                '-${_formatDuration(remaining)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
