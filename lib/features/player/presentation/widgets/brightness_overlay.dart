import 'package:flutter/material.dart';

/// A vertical overlay to show brightness changes during gestures.
class BrightnessOverlay extends StatelessWidget {
  final double brightness; // 0.0 to 1.0

  const BrightnessOverlay({super.key, required this.brightness});

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
          const Icon(Icons.brightness_medium, color: Colors.white),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            width: 4,
            child: LinearProgressIndicator(
              value: brightness,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
