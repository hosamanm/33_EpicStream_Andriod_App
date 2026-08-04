import 'package:flutter/material.dart';

/// A toggle button for switching between fullscreen and normal mode.
class FullscreenButton extends StatelessWidget {
  final bool isFullscreen;
  final VoidCallback onToggle;

  const FullscreenButton({
    super.key,
    required this.isFullscreen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: Colors.white,
        size: 28,
      ),
      onPressed: onToggle,
    );
  }
}
