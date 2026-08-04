import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/features/movies/domain/entities/movie_entity.dart';
import 'package:epic_stream/features/categories/domain/entities/category_entity.dart';
import 'package:epic_stream/features/categories/domain/entities/genre_entity.dart';
import 'package:epic_stream/features/home/presentation/controllers/home_controller.dart';
import 'package:epic_stream/features/home/presentation/providers/home_provider.dart';
import 'package:epic_stream/features/home/presentation/providers/home_state.dart';
import 'package:epic_stream/core/di/injection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(
      context.read<HomeProvider>(),
      sl(),
      sl(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HomeProvider>().state;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: RefreshIndicator(
        color: AppColors.primaryRed,
        onRefresh: () => _controller.fetchHomeData(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const _HomeAppBar(),
            SliverToBoxAdapter(
              child: _buildBody(state),
            ),
            const SliverToBoxAdapter(
              child: _HomeFooter(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(HomeState state) {
    if (state is HomeInitial || state is HomeLoading) {
      return const _HomeLoadingSkeleton();
    }
    if (state is HomeError) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: AppErrorView(
          message: state.message,
          onRetry: () => _controller.fetchHomeData(),
        ),
      );
    }
    if (state is HomeLoaded) {
      return const _HomeContent();
    }
    return const SizedBox.shrink();
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.black.withOpacity(0.8),
      elevation: 0,
      floating: true,
      pinned: false,
      centerTitle: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_fill, color: AppColors.primaryRed, size: 28),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'EPICSTREAM',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: const Icon(Icons.search, color: Colors.white, size: 22),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 22),
          visualDensity: VisualDensity.compact,
        ),
        const Padding(
          padding: EdgeInsets.only(left: 4, right: 12),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.darkSurface,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=ott_user'),
          ),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<HomeProvider>().loadedState!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroBanner(items: data.heroBanners),
        const SizedBox(height: AppDimensions.l),
        
        if (data.continueWatching.isNotEmpty)
          _MovieSection(
            title: 'Continue Watching',
            movies: data.continueWatching,
            isWide: true,
            showProgress: true,
          ),
          
        _CategorySection(categories: data.categories),
        
        _MovieSection(title: 'Trending Now', movies: data.trending),
        
        _GenreSection(genres: data.genres),
        
        _MovieSection(title: 'Popular on EpicStream', movies: data.popular),
        _MovieSection(title: 'New Releases', movies: data.latest),
        _MovieSection(title: 'Recommended for You', movies: data.recommended),
        
        const SizedBox(height: AppDimensions.xxl),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final List<MovieEntity> items;
  const _HeroBanner({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.55,
      child: PageView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final movie = items[index];
          return GestureDetector(
            onTap: () => context.push('/movie-details/${movie.movieId}'),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: movie.bannerUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.black26),
                  errorWidget: (context, url, error) => Container(color: Colors.black45),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black54,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        movie.title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.shortDescription,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => context.push('/player/${movie.movieId}'),
                            icon: const Icon(Icons.play_arrow, size: 28),
                            label: const Text('WATCH NOW', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filledTonal(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white10,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MovieSection extends StatelessWidget {
  final String title;
  final List<MovieEntity> movies;
  final bool isWide;
  final bool showProgress;

  const _MovieSection({
    required this.title,
    required this.movies,
    this.isWide = false,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('See All', style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: isWide ? 160 : 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => context.push('/movie-details/${movie.movieId}'),
                child: Container(
                  width: isWide ? 260 : 140,
                  margin: const EdgeInsets.only(right: AppDimensions.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: isWide ? movie.bannerUrl : movie.posterUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(color: Colors.white10),
                                errorWidget: (context, url, error) => Container(color: Colors.white12),
                              ),
                              if (showProgress)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: LinearProgressIndicator(
                                    value: 0.7, 
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                                    minHeight: 3,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isWide) ...[
                        const SizedBox(height: 6),
                        Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.m),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<CategoryEntity> categories;
  const _CategorySection({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
          child: Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: AppDimensions.m),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: cat.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorWidget: (_, __, ___) => Container(color: Colors.white10),
                      ),
                      Container(color: Colors.black38),
                      Center(
                        child: Text(
                          cat.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.l),
      ],
    );
  }
}

class _GenreSection extends StatelessWidget {
  final List<GenreEntity> genres;
  const _GenreSection({required this.genres});

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
          child: Text(
            'Popular Genres',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          ),
        ),
        SizedBox(
          height: 45,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              return Container(
                margin: const EdgeInsets.only(right: 10),
                child: ActionChip(
                  label: Text(genre.name),
                  onPressed: () {},
                  backgroundColor: AppColors.darkSurface,
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                  side: const BorderSide(color: Colors.white12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.l),
      ],
    );
  }
}

class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Column(
        children: [
          Container(height: 350, color: Colors.black),
          const SizedBox(height: 20),
          _buildShimmerSection(),
          _buildShimmerSection(),
        ],
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(margin: const EdgeInsets.all(16), height: 18, width: 140, color: Colors.black),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 5,
            itemBuilder: (_, __) => Container(
              width: 120,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeFooter extends StatelessWidget {
  const _HomeFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      color: Colors.black.withOpacity(0.4),
      child: Column(
        children: [
          const Icon(Icons.play_circle_fill, color: AppColors.primaryRed, size: 48),
          const SizedBox(height: 16),
          const Text(
            'EPICSTREAM',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 EpicStream OTT. Premium entertainment on demand.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white38),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(label: 'Privacy', onTap: () {}),
              const _Dot(),
              _FooterLink(label: 'Terms', onTap: () {}),
              const _Dot(),
              _FooterLink(label: 'Contact', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text('•', style: TextStyle(color: Colors.white24)),
  );
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white54, fontSize: 11),
      ),
    );
  }
}
