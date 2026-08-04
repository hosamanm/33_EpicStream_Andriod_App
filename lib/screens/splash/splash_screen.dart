import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/controllers/splash_animation_controller.dart';
import 'package:epic_stream/widgets/particles.dart';
import 'package:epic_stream/widgets/glow_ring.dart';
import 'package:epic_stream/widgets/logo_shimmer.dart';
import 'package:epic_stream/widgets/animated_tagline.dart';
import 'package:epic_stream/features/auth/presentation/providers/splash_notifier.dart';

/// Premium cinematic Splash Screen for EpicStream.
class EpicStreamSplashScreen extends StatefulWidget {
  const EpicStreamSplashScreen({super.key});

  @override
  State<EpicStreamSplashScreen> createState() => _EpicStreamSplashScreenState();
}

class _EpicStreamSplashScreenState extends State<EpicStreamSplashScreen> with TickerProviderStateMixin {
  late final SplashAnimationController _controller;
  late final SplashNotifier _splashNotifier;

  @override
  void initState() {
    super.initState();
    _splashNotifier = context.read<SplashNotifier>();
    
    // Use immersive mode for the cinematic experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _controller = SplashAnimationController(vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start background initialization logic
      _splashNotifier.initializeApp();
      
      // Start the 4-second cinematic timeline
      _controller.forward();
    });

    // Backup listener to ensure transition if router refresh is delayed
    _splashNotifier.addListener(_onSplashStateChanged);
  }

  void _onSplashStateChanged() {
    if (_splashNotifier.step == SplashStep.completed) {
      // We don't call context.go here anymore to let AppRouter handle it exclusively.
      // But we ensure the animation has reached a stable end state.
      debugPrint('SplashScreen: Initialization completed detected in widget');
    }
  }

  @override
  void dispose() {
    _splashNotifier.removeListener(_onSplashStateChanged);
    // Restore system bars
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for fatal errors during initialization
    final errorMsg = context.select<SplashNotifier, String?>((n) => n.errorMessage);
    
    if (errorMsg != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMsg, 
                  style: const TextStyle(color: Colors.white70), 
                  textAlign: TextAlign.center
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.read<SplashNotifier>().initializeApp(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white12),
                child: const Text('RETRY', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const _CinematicBackground(),
            const RepaintBoundary(child: EpicParticles()),
            
            // Central Aura
            AnimatedBuilder(
              animation: _controller.glowAnimation,
              builder: (context, child) => Opacity(
                opacity: _controller.glowAnimation.value,
                child: GlowRing(scale: _controller.ringScaleAnimation.value),
              ),
            ),

            // Shimmering Logo
            AnimatedBuilder(
              animation: _controller.controller,
              builder: (context, child) => Opacity(
                opacity: _controller.logoAnimation.value,
                child: Transform.scale(
                  scale: _controller.logoScaleAnimation.value,
                  child: LogoShimmer(
                    shimmerValue: _controller.shimmerAnimation.value,
                    child: const Image(
                      image: AssetImage('assets/images/app_logo.png'),
                      width: 240,
                      errorBuilder: _imageErrorBuilder,
                    ),
                  ),
                ),
              ),
            ),

            // Tagline
            Positioned(
              bottom: 100,
              child: AnimatedTagline(
                opacity: _controller.taglineAnimation,
                slide: _controller.taglineSlideAnimation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _imageErrorBuilder(BuildContext context, Object error, StackTrace? stackTrace) {
    return const Icon(Icons.play_circle_fill, color: Colors.red, size: 100);
  }
}

class _CinematicBackground extends StatelessWidget {
  const _CinematicBackground();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0E21), Color(0xFF000B18), Color(0xFF050505)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
