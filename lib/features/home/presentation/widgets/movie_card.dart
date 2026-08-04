import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/media_item.dart';

/// Extension to MediaItem for UI-specific flags used in this prompt
class MovieCardModel extends MediaItem {
  final bool isNew;
  final double? watchProgress; // 0.0 to 1.0
  final bool isFavorite;

  const MovieCardModel({
    required super.id,
    required super.title,
    required super.posterUrl,
    super.backdropUrl,
    super.rating,
    super.year,
    this.isNew = false,
    this.watchProgress,
    this.isFavorite = false,
  });
}

/// Base Wrapper for all Movie Cards to handle common animations and gestures.
class MovieCardBase extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String heroTag;

  const MovieCardBase({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    required this.heroTag,
  });

  @override
  State<MovieCardBase> createState() => _MovieCardBaseState();
}

class _MovieCardBaseState extends State<MovieCardBase> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.95);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Hero(
        tag: widget.heroTag,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Common components used within cards
class CardBadge extends StatelessWidget {
  final String text;
  final Color color;
  const CardBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
