import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../painters/particle_painter.dart';

/// Performance-optimized particle system widget.
/// 
/// Features:
/// - Generates 40-60 random cinematic particles.
/// - Self-contained animation loop at 60 FPS.
/// - Responsive design using normalized coordinates.
/// - RepaintBoundary friendly for maximum optimization.
class EpicParticles extends StatefulWidget {
  const EpicParticles({super.key});

  @override
  State<EpicParticles> createState() => _EpicParticlesState();
}

class _EpicParticlesState extends State<EpicParticles> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  final List<ParticleModel> _particles = [];
  final math.Random _random = math.Random();
  
  // Cinematic Palette: Deep Blues, Cyans, and subtle Purples
  final List<Color> _palette = [
    const Color(0xFF00B4DB),
    const Color(0xFF0083B0),
    const Color(0xFF4389A2),
    const Color(0xFF5C258D),
  ];

  @override
  void initState() {
    super.initState();
    _initParticles();
    
    // Dedicated loop for particle movement
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateParticles);
    
    _animationController.repeat();
  }

  void _initParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(
        ParticleModel(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          vx: (_random.nextDouble() - 0.5) * 0.002, // Slow drifting
          vy: (_random.nextDouble() - 0.5) * 0.002,
          radius: _random.nextDouble() * 2 + 1,
          opacity: _random.nextDouble() * 0.4 + 0.1,
          blurRadius: _random.nextDouble() * 4 + 2,
          color: _palette[_random.nextInt(_palette.length)],
        ),
      );
    }
  }

  void _updateParticles() {
    for (var particle in _particles) {
      particle.update();
    }
    setState(() {}); // Triggers the CustomPaint repaint
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: ParticlePainter(particles: _particles),
      ),
    );
  }
}
