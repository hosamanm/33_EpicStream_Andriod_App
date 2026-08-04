import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';
import 'movie_card.dart';

/// A compact Movie Card for tight spaces like "More Like This" or "Search Suggestions".
class SmallMovieCard extends StatelessWidget {
  final MovieCardModel movie;
  final VoidCallback onTap;

  const SmallMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MovieCardBase(
      heroTag: 'small_${movie.id}',
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppDimensions.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: CachedNetworkImage(
                  imageUrl: movie.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.white10),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              movie.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
