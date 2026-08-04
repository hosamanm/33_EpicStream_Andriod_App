import 'package:flutter/material.dart';

/// A shader-based light sweep effect for branding.
/// 
/// Features:
/// - Uses ShaderMask for non-destructive image effects.
/// - Animated LinearGradient to simulate a light source moving across the logo.
/// - Designed to be used within an AnimatedBuilder.
class LogoShimmer extends StatelessWidget {
  final Widget child;
  final double? shimmerValue;

  const LogoShimmer({
    super.key,
    required this.child,
    this.shimmerValue,
  });

  @override
  Widget build(BuildContext context) {
    // If no shimmerValue is provided, we just render the child.
    if (shimmerValue == null) return child;

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [
            shimmerValue! - 0.2,
            shimmerValue!,
            shimmerValue! + 0.2,
          ],
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
