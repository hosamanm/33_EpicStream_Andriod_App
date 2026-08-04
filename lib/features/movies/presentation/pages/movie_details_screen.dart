import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../home/presentation/widgets/movie_grid_card.dart';
import '../../../home/presentation/widgets/movie_card.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_member.dart';
import '../providers/movie_details_provider.dart';
import '../providers/movie_details_state.dart';
import '../controllers/movie_details_controller.dart';

/// A Movie Details Screen featuring a collapsing banner, 
/// Hero animations, and rich metadata display.
class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late MovieDetailsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MovieDetailsController(context.read<MovieDetailsProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMovieDetails(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MovieDetailsProvider>().state;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _buildBody(state),
    );
  }

  Widget _buildBody(MovieDetailsState state) {
    return switch (state) {
      MovieDetailsInitial() || MovieDetailsLoading() => const _MovieDetailsSkeleton(),
      MovieDetailsError(message: final msg) => AppErrorView(
          message: msg,
          onRetry: () => _controller.loadMovieDetails(widget.movieId),
        ),
      MovieDetailsLoaded() => _MovieDetailsContent(controller: _controller),
    };
  }
}

class _MovieDetailsContent extends StatelessWidget {
  final MovieDetailsController controller;
  const _MovieDetailsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<MovieDetailsProvider>().loadedState!;
    final movie = data.movie;

    return CustomScrollView(
      slivers: [
        // 1. Collapsing Banner
        _CollapsingBanner(movie: movie),

        // 2. Movie Metadata & Main Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MovieMetadata(movie: movie),
                const SizedBox(height: AppDimensions.l),
                _MainActionButtons(movie: movie),
                const SizedBox(height: AppDimensions.l),
                _SecondaryActionRow(
                  movie: movie,
                  isInWatchlist: data.isInWatchlist,
                  isFavorite: data.isFavorite,
                  onWatchlistToggle: () => controller.toggleWatchlist(),
                  onFavoriteToggle: () => controller.toggleFavorite(),
                ),
                const SizedBox(height: AppDimensions.xl),
                
                // Description
                Text(
                  'STORYLINE',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppDimensions.s),
                Text(
                  movie.longDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Cast
                _CastSection(cast: movie.cast),
                const SizedBox(height: AppDimensions.xl),

                // Crew/Studio Info
                _InfoTile(label: 'Director', value: movie.director),
                if (movie.producer != null) _InfoTile(label: 'Producer', value: movie.producer!),
                if (movie.studio != null) _InfoTile(label: 'Studio', value: movie.studio!),
                if (movie.writer != null) _InfoTile(label: 'Writer', value: movie.writer!),
                const SizedBox(height: AppDimensions.xl),

                // Recommendations
                if (data.recommendations.isNotEmpty) ...[
                  Text(
                    'YOU MAY ALSO LIKE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.m),
                ],
              ],
            ),
          ),
        ),

        // 3. Recommended Movies Grid
        if (data.recommendations.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.l),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2 / 3.5,
                mainAxisSpacing: AppDimensions.m,
                crossAxisSpacing: AppDimensions.m,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final rec = data.recommendations[index];
                  return MovieGridCard(
                    movie: MovieCardModel(
                      id: rec.movieId,
                      title: rec.title,
                      posterUrl: rec.posterUrl,
                      rating: rec.imdbRating.toString(),
                    ),
                    onTap: () {
                      context.pushReplacement('/movie-details/${rec.movieId}');
                    },
                  );
                },
                childCount: data.recommendations.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.xxl)),
      ],
    );
  }
}

class _CollapsingBanner extends StatelessWidget {
  final MovieEntity movie;
  const _CollapsingBanner({required this.movie});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      backgroundColor: AppColors.darkBackground,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'hero_banner_${movie.movieId}',
              child: CachedNetworkImage(
                imageUrl: movie.bannerUrl,
                fit: BoxFit.cover,
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black45,
                    Colors.transparent,
                    AppColors.darkBackground,
                  ],
                ),
              ),
            ),
            // Movie Logo Overlay
            if (movie.logoUrl != null)
              Positioned(
                bottom: 40,
                left: 20,
                child: CachedNetworkImage(imageUrl: movie.logoUrl!, height: 60),
              ),
          ],
        ),
      ),
    );
  }
}

class _MovieMetadata extends StatelessWidget {
  final MovieEntity movie;
  const _MovieMetadata({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          movie.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.s),
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaItem(text: '${movie.releaseYear}', color: Colors.white70),
            _MetaItem(text: movie.ageRating, isBordered: true),
            _MetaItem(text: '${movie.duration ~/ 60}h ${movie.duration % 60}m', color: Colors.white70),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${movie.imdbRating}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.m),
        Text(
          movie.genreNames.join(' • '),
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final String text;
  final bool isBordered;
  final Color? color;

  const _MetaItem({required this.text, this.isBordered = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isBordered ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) : null,
      decoration: isBordered ? BoxDecoration(border: Border.all(color: Colors.white38, width: 0.5)) : null,
      child: Text(
        text,
        style: TextStyle(color: color ?? Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _MainActionButtons extends StatelessWidget {
  final MovieEntity movie;
  const _MainActionButtons({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/player/${movie.movieId}'),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text('WATCH NOW'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.m),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              if (movie.trailerVideoId != null) {
                context.push('/player/${movie.movieId}?isTrailer=true');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trailer not available')),
                );
              }
            },
            icon: const Icon(Icons.movie_outlined),
            label: const Text('TRAILER'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecondaryActionRow extends StatelessWidget {
  final MovieEntity movie;
  final bool isInWatchlist;
  final bool isFavorite;
  final VoidCallback onWatchlistToggle;
  final VoidCallback onFavoriteToggle;

  const _SecondaryActionRow({
    required this.movie,
    required this.isInWatchlist,
    required this.isFavorite,
    required this.onWatchlistToggle,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: isInWatchlist ? Icons.check : Icons.add,
          label: 'My List',
          onTap: onWatchlistToggle,
          isActive: isInWatchlist,
        ),
        _ActionButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          label: 'Favorite',
          onTap: onFavoriteToggle,
          isActive: isFavorite,
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {
            Share.share(
              'Check out ${movie.title} on EpicStream! \nWatch here: https://epicstream.com/movie/${movie.movieId}',
            );
          },
        ),
        _ActionButton(icon: Icons.download_for_offline_outlined, label: 'Download', onTap: () {}),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: isActive ? AppColors.primaryRed : Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

class _CastSection extends StatelessWidget {
  final List<CastMember> cast;
  const _CastSection({required this.cast});

  @override
  Widget build(BuildContext context) {
    if (cast.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CAST',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        const SizedBox(height: AppDimensions.m),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final member = cast[index];
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: AppDimensions.m),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: AppColors.darkSurface,
                      backgroundImage: member.profileUrl != null 
                          ? CachedNetworkImageProvider(member.profileUrl!) 
                          : null,
                      child: member.profileUrl == null 
                          ? const Icon(Icons.person, color: Colors.white24) 
                          : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      member.character,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 9),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieDetailsSkeleton extends StatelessWidget {
  const _MovieDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 350, color: Colors.black),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 30, width: 200, color: Colors.black),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 150, color: Colors.black),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: Container(height: 50, color: Colors.black)),
                      const SizedBox(width: 16),
                      Expanded(child: Container(height: 50, color: Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
