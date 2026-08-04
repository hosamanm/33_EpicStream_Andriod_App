import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A dialog to select video playback speed.
class PlaybackSpeedDialog extends StatelessWidget {
  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  const PlaybackSpeedDialog({
    super.key,
    required this.currentSpeed,
    required this.onSpeedSelected,
  });

  static const List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Playback Speed', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.black87,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _speeds.map((speed) {
          final isSelected = speed == currentSpeed;
          return ListTile(
            title: Text(
              '${speed}x',
              style: TextStyle(
                color: isSelected ? AppColors.primaryRed : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check, color: AppColors.primaryRed) 
                : null,
            onTap: () {
              onSpeedSelected(speed);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
