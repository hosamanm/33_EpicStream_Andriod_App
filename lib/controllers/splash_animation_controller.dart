import 'package:flutter/material.dart';

/// Manages the cinematic timeline for EpicStream.
/// 
/// Uses staggered animations to ensure frame-perfect transitions 
/// between glow, logo, shimmer, and tagline.
class SplashAnimationController {
  final AnimationController controller;

  // Staggered animation components
  late final Animation<double> glowAnimation;
  late final Animation<double> ringScaleAnimation;
  late final Animation<double> logoAnimation;
  late final Animation<double> logoScaleAnimation;
  late final Animation<double> shimmerAnimation;
  late final Animation<double> taglineAnimation;
  late final Animation<Offset> taglineSlideAnimation;

  SplashAnimationController({required TickerProvider vsync})
      : controller = AnimationController(
          vsync: vsync,
          duration: const Duration(seconds: 6), // Increased from 4 to 6 seconds
        ) {
    _initAnimations();
  }

  void _initAnimations() {
    // Note: Intervals are normalized (0.0 to 1.0), so they automatically 
    // scale with the AnimationController's total duration.

    // 0.75s -> 2.25s (approx in 6s timeline)
    glowAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.125, 0.375, curve: Curves.easeIn),
    );

    // 1.5s -> 3.75s
    ringScaleAnimation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.25, 0.625, curve: Curves.easeOutCirc),
      ),
    );

    // 3.0s -> 4.2s
    logoAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 0.7, curve: Curves.easeIn),
    );

    // 3.3s -> 4.5s
    logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.55, 0.75, curve: Curves.elasticOut),
      ),
    );

    // 4.2s -> 5.7s
    shimmerAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.7, 0.95, curve: Curves.easeInOut),
    );

    // 4.8s -> 6.0s
    taglineAnimation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
    );

    taglineSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.8, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  Future<void> forward() => controller.forward();

  void dispose() => controller.dispose();
}
