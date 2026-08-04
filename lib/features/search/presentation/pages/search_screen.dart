import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/di/injection.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/features/categories/presentation/widgets/filter_bottom_sheet.dart';
import 'package:epic_stream/features/movies/presentation/pages/movie_details_screen.dart';
import 'package:epic_stream/features/search/presentation/providers/search_provider.dart';
import 'package:epic_stream/features/search/presentation/providers/recent_search_provider.dart';
import 'package:epic_stream/features/search/presentation/controllers/search_controller.dart';
import 'package:epic_stream/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:epic_stream/features/search/presentation/widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // Using sl for the controller ensures we use the same instances as the providers
  final SearchModuleController _controller = sl<SearchModuleController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider state changes for UI updates
    final searchProvider = context.watch<SearchProvider>();
    final recentProvider = context.watch<RecentSearchProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
          child: SearchBarWidget(
            controller: _searchController,
            onChanged: _controller.onSearchChanged,
            onClear: () {
              _searchController.clear();
              _controller.clearSearch();
            },
            onVoiceSearch: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice Search Coming Soon')),
              );
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: AppDimensions.s),
        ],
      ),
      body: _buildBody(searchProvider, recentProvider, theme),
    );
  }

  Widget _buildBody(SearchProvider search, RecentSearchProvider recent, ThemeData theme) {
    if (search.status == SearchStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (search.query.isEmpty) {
      return _buildDiscoveryView(recent, theme);
    }

    return switch (search.status) {
      SearchStatus.success => _buildResultsList(search),
      SearchStatus.noResults => const AppErrorView(
          type: ErrorViewType.empty,
          title: 'No Results Found',
          message: 'Try different keywords or filters.',
        ),
      SearchStatus.error => AppErrorView(
          message: search.errorMessage,
          onRetry: () => _controller.performSearch(search.query),
        ),
      _ => _buildDiscoveryView(recent, theme),
    };
  }

  Widget _buildResultsList(SearchProvider search) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.m),
      itemCount: search.results.length,
      itemBuilder: (context, index) {
        final movie = search.results[index];
        return SearchResultCard(
          movie: movie,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailsScreen(movieId: movie.movieId),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiscoveryView(RecentSearchProvider recent, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.history.isNotEmpty) ...[
            _SectionHeader(
              title: 'Recent Searches',
              onAction: recent.clearHistory,
              actionLabel: 'Clear',
            ),
            Wrap(
              spacing: 8,
              children: recent.history.map((q) => _SearchChip(
                label: q, 
                onTap: () {
                  _searchController.text = q;
                  _controller.performSearch(q);
                },
              )).toList(),
            ),
            const SizedBox(height: AppDimensions.l),
          ],
          
          const _SectionHeader(title: 'Trending Searches'),
          Wrap(
            spacing: 8,
            children: const ['Interstellar', 'Nolan', 'Sci-Fi', 'Action 2024', 'Marvel']
                .map((q) => _SearchChip(
                  label: q, 
                  isTrending: true,
                  onTap: () {
                    _searchController.text = q;
                    _controller.performSearch(q);
                  },
                )).toList(),
          ),
          
          const SizedBox(height: AppDimensions.l),
          const _SectionHeader(title: 'Suggested Categories'),
          const _SuggestedGrid(),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _SectionHeader({required this.title, this.onAction, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel ?? '')),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final bool isTrending;
  final VoidCallback onTap;

  const _SearchChip({required this.label, this.isTrending = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: isTrending ? const Icon(Icons.trending_up, size: 14, color: AppColors.primaryRed) : null,
      backgroundColor: Colors.white.withOpacity(0.05),
      side: const BorderSide(color: Colors.white12),
      labelStyle: const TextStyle(fontSize: 12, color: Colors.white70),
    );
  }
}

class _SuggestedGrid extends StatelessWidget {
  const _SuggestedGrid();

  @override
  Widget build(BuildContext context) {
    final list = [
      {'name': 'Actors', 'icon': Icons.person_outline},
      {'name': 'Directors', 'icon': Icons.movie_creation_outlined},
      {'name': 'Oscars', 'icon': Icons.emoji_events_outlined},
      {'name': '4K HDR', 'icon': Icons.high_quality_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(list[index]['icon'] as IconData, size: 20, color: AppColors.primaryRed),
              const SizedBox(width: 8),
              Text(list[index]['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      },
    );
  }
}
