import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'movie_card.dart';

/// A Large Movie Card typically used for "Recommended" or "Editor's Choice" sections.
/// It emphasizes high-quality backdrop visuals.
class LargeMovieCard extends StatelessWidget {
  final MovieCardModel movie;
  final VoidCallback onTap;

  const LargeMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return MovieCardBase(
      heroTag: 'large_${movie.id}',
      onTap: onTap,
      child: Container(
        width: isTablet ? 500 : size.width * 0.9,
        margin: const EdgeInsets.only(right: AppDimensions.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.backdropUrl ?? movie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.white10),
                    ),
                    // Vignette Overlay
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    // Top Badges
                    if (movie.isNew)
                      const Positioned(
                        top: 16,
                        left: 16,
                        child: CardBadge(text: 'NEW', color: AppColors.primaryRed),
                      ),
                    // Favorite Icon
                    Positioned(
                      top: 12,
                      right: 12,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: movie.isFavorite ? AppColors.primaryRed : Colors.white,
                        ),
                      ),
                    ),
                    // Content Info
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                movie.rating ?? '0.0',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                movie.year ?? '',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
