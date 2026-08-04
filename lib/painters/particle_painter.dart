import 'package:flutter/material.dart';

/// Data model for an individual particle in the EpicStream Splash.
class ParticleModel {
  double x; // Normalized 0.0 to 1.0
  double y; // Normalized 0.0 to 1.0
  final double vx;
  final double vy;
  final double radius;
  final double opacity;
  final double blurRadius;
  final Color color;

  ParticleModel({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.opacity,
    required this.blurRadius,
    required this.color,
  });

  /// Updates particle position based on velocity and handles screen wrapping.
  void update() {
    x += vx;
    y += vy;

    if (x > 1.0) x = 0.0;
    if (x < 0.0) x = 1.0;
    if (y > 1.0) y = 0.0;
    if (y < 0.0) y = 1.0;
  }
}

/// CustomPainter for the cinematic particle system.
///
/// Features:
/// - Efficiently renders a list of particles with blur effects.
/// - Uses normalized coordinates (0.0 to 1.0) for full responsiveness.
/// - Implements dual-layer rendering (Aura + Core) for "premium" glow.
class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // 1. Draw the particle Aura (Glow)
      final Paint auraPaint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particle.blurRadius);

      final center = Offset(particle.x * size.width, particle.y * size.height);

      canvas.drawCircle(
        center,
        particle.radius * 2, // Aura is larger than the core
        auraPaint,
      );
      
      // 2. Draw the particle Core (Brighter center)
      final Paint corePaint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity * 0.9);
      
      canvas.drawCircle(
        center,
        particle.radius * 0.5,
        corePaint,
      );
    }
  }

  // We return true because the particles are constantly moving
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
