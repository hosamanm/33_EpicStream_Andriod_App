import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:epic_stream/features/watchlist/presentation/controllers/watchlist_controller.dart';
import 'package:epic_stream/features/movies/presentation/pages/movie_details_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Corrected method name to match WatchlistProvider.init()
      context.read<WatchlistProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _buildContent(provider),
    );
  }

  Widget _buildContent(WatchlistProvider provider) {
    // Corrected check to use the status enum
    if (provider.status == WatchlistStatus.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (provider.movies.isEmpty) {
      return const AppErrorView(
        type: ErrorViewType.empty,
        title: 'Watchlist is Empty',
        message: 'Save movies to watch them later!',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.m),
      itemCount: provider.movies.length,
      itemBuilder: (context, index) {
        final movie = provider.movies[index];
        return ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.movieId)),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: movie.posterUrl.isNotEmpty 
              ? Image.network(movie.posterUrl, width: 50, height: 75, fit: BoxFit.cover)
              : Container(width: 50, height: 75, color: Colors.white10),
          ),
          title: Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${movie.releaseYear} • ${movie.genreNames.join(', ')}'),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            // Corrected method name to match toggleWatchlist
            onPressed: () => context.read<WatchlistController>().toggleWatchlist(movie.movieId),
          ),
        );
      },
    );
  }
}
