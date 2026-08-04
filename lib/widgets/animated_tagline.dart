import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated Tagline for the EpicStream splash sequence.
/// 
/// Features:
/// - "WATCH ANYWHERE. ANYTIME." text.
/// - Integrated Fade and Slide-up animations.
/// - Premium typography using Google Fonts.
class AnimatedTagline extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<Offset> slide;

  const AnimatedTagline({
    super.key,
    required this.opacity,
    required this.slide,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(
        position: slide,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'WATCH ANYWHERE.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'ANYTIME.',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 12,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
