import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/movie_provider.dart';
import '../controllers/movie_management_controller.dart';
import '../widgets/movie_table.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late MovieManagementController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = MovieManagementController(context.read<AdminMovieProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMovieProvider>().fetchMovies();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _controller.onAddMovie(context),
            icon: const Icon(Icons.add),
            label: const Text('ADD MOVIE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search by title...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AdminColors.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _FilterDropdown(
                  label: 'Status',
                  items: const ['All', 'Published', 'Draft', 'Archived'],
                  onChanged: (val) {},
                ),
                const SizedBox(width: 16),
                _FilterDropdown(
                  label: 'Type',
                  items: const ['All', 'Action', 'Sci-Fi', 'Drama'],
                  onChanged: (val) {},
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminMovieProvider provider) {
    if (provider.status == MovieManagementStatus.loading && provider.movies.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == MovieManagementStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchMovies(isRefresh: true),
      );
    }

    if (provider.movies.isEmpty) {
      return const Center(child: Text('No movies found. Add your first movie!'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AdminColors.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: MovieTable(
          movies: provider.filteredMovies,
          controller: _controller,
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.label, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: items.first,
        hint: Text(label),
        underline: const SizedBox(),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
