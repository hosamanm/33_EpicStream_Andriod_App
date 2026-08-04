import 'package:flutter/material.dart';

/// A layered atmospheric glow effect for the EpicStream splash sequence.
/// 
/// Features:
/// - Triple-layered blurring for deep aura effect
/// - Tri-color cinematic gradient (Blue, Purple, Orange)
/// - Pulse and expansion synchronization
class GlowRing extends StatelessWidget {
  final double scale;

  const GlowRing({
    super.key,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Primary Deep Aura (Dark Blue/Navy)
          _GlowLayer(
            size: 300,
            blur: 80,
            opacity: 0.15,
            color: const Color(0xFF001242),
          ),
          
          // 2. Mid Aura (Royal Blue/Purple)
          _GlowLayer(
            size: 200,
            blur: 50,
            opacity: 0.2,
            color: const Color(0xFF0052D4),
          ),
          
          // 3. Highlight Aura (Vibrant Blue/Cyan)
          _GlowLayer(
            size: 100,
            blur: 30,
            opacity: 0.3,
            color: const Color(0xFF4389A2),
          ),

          // 4. Subtle Cinematic Accent (Orange/Purple Rim)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                  Colors.blue.withOpacity(0.2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowLayer extends StatelessWidget {
  final double size;
  final double blur;
  final double opacity;
  final Color color;

  const _GlowLayer({
    required this.size,
    required this.blur,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: blur,
            spreadRadius: blur / 2,
          ),
        ],
      ),
    );
  }
}
