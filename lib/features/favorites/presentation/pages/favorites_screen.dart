import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:epic_stream/features/favorites/presentation/widgets/favorite_movie_card.dart';
import 'package:epic_stream/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:epic_stream/features/favorites/data/services/favorite_service.dart';
import 'package:epic_stream/features/movies/presentation/pages/movie_details_screen.dart';

/// The Favorites Screen allows users to browse their liked movies, actors, and directors.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late FavoriteController _controller;

  @override
  void initState() {
    super.initState();
    // Explicitly type the provider lookups
    _controller = FavoriteController(
      favoriteService: context.read<FavoriteService>(),
      provider: context.read<FavoriteProvider>(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: _buildTabBar(provider),
        ),
      ),
      body: _buildContent(provider),
    );
  }

  Widget _buildTabBar(FavoriteProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
      child: Row(
        children: [
          _TabItem(
            label: 'Movies',
            isSelected: provider.currentTab == FavoriteTab.movies,
            onTap: () => provider.setTab(FavoriteTab.movies),
          ),
          const SizedBox(width: AppDimensions.s),
          _TabItem(
            label: 'Actors',
            isSelected: provider.currentTab == FavoriteTab.actors,
            onTap: () => provider.setTab(FavoriteTab.actors),
          ),
          const SizedBox(width: AppDimensions.s),
          _TabItem(
            label: 'Directors',
            isSelected: provider.currentTab == FavoriteTab.directors,
            onTap: () => provider.setTab(FavoriteTab.directors),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(FavoriteProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (provider.favorites.isEmpty) {
      return AppErrorView(
        type: ErrorViewType.empty,
        title: 'No Favorites Yet',
        message: 'Items you heart will appear here.',
        onAction: () => _controller.refresh(),
        actionLabel: 'Refresh',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppDimensions.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2 / 3.5,
        mainAxisSpacing: AppDimensions.m,
        crossAxisSpacing: AppDimensions.m,
      ),
      itemCount: provider.favorites.length,
      itemBuilder: (context, index) {
        final item = provider.favorites[index];
        return FavoriteMovieCard(
          favorite: item,
          onTap: () {
            if (item.type == 'movie' || item.type == 'tv_show') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailsScreen(movieId: item.id),
                ),
              );
            }
          },
          onRemove: () => _controller.toggleFavorite(item),
        );
      },
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
