import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'movie_card.dart';

/// A horizontal Movie Card for lists, search results, or history.
class MovieListCard extends StatelessWidget {
  final MovieCardModel movie;
  final VoidCallback onTap;

  const MovieListCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MovieCardBase(
      heroTag: 'list_${movie.id}',
      onTap: onTap,
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: AppDimensions.m),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          children: [
            // Poster
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                bottomLeft: Radius.circular(AppDimensions.radiusM),
              ),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 70,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppDimensions.m),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      movie.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year ?? 'N/A'} • ${movie.rating ?? '0.0'} Rating',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
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
