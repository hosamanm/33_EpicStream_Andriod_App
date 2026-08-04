import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'movie_card.dart';
import 'movie_grid_card.dart';
import 'featured_movie_card.dart';
import 'large_movie_card.dart';

enum SectionLayout { portrait, landscape, large }

/// A high-performance horizontal scrollable list for movie items.
/// Supports different card layouts (Portrait, Landscape, Large).
class HorizontalMovieList extends StatelessWidget {
  final List<MovieCardModel> items;
  final SectionLayout layout;
  final void Function(MovieCardModel) onMovieTap;

  const HorizontalMovieList({
    super.key,
    required this.items,
    this.layout = SectionLayout.portrait,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _calculateHeight(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.m),
            child: _buildCard(item),
          );
        },
      ),
    );
  }

  double _calculateHeight(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    switch (layout) {
      case SectionLayout.portrait:
        return 220; // Aspect ratio ~2:3 + title space
      case SectionLayout.landscape:
        return 180; // Aspect ratio ~16:9
      case SectionLayout.large:
        return width > 600 ? 320 : 260; // Larger highlights
    }
  }

  Widget _buildCard(MovieCardModel item) {
    switch (layout) {
      case SectionLayout.portrait:
        return SizedBox(
          width: 140,
          child: MovieGridCard(
            movie: item,
            onTap: () => onMovieTap(item),
          ),
        );
      case SectionLayout.landscape:
        return FeaturedMovieCard(
          movie: item,
          onTap: () => onMovieTap(item),
        );
      case SectionLayout.large:
        return LargeMovieCard(
          movie: item,
          onTap: () => onMovieTap(item),
        );
    }
  }
}
