import 'package:flutter/material.dart';

/// A vertical overlay to show volume changes during gestures.
class VolumeOverlay extends StatelessWidget {
  final double volume; // 0.0 to 1.0

  const VolumeOverlay({super.key, required this.volume});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            volume <= 0
                ? Icons.volume_mute
                : volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: 4,
            child: LinearProgressIndicator(
              value: volume,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
