import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../providers/movie_provider.dart';
import '../providers/movie_upload_provider.dart';
import '../widgets/video_picker_widget.dart';

class TrailersScreen extends StatefulWidget {
  const TrailersScreen({super.key});

  @override
  State<TrailersScreen> createState() => _TrailersScreenState();
}

class _TrailersScreenState extends State<TrailersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMovieProvider>().fetchMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminMovieProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trailer Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchMovies(isRefresh: true),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AdminMovieProvider provider) {
    if (provider.status == MovieManagementStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == MovieManagementStatus.error) {
      return AppErrorView(message: provider.errorMessage, onRetry: () => provider.fetchMovies());
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: provider.movies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final movie = provider.movies[index];
        final hasTrailer = movie.trailerPlaybackUrl != null && movie.trailerPlaybackUrl!.isNotEmpty;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AdminColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(movie.posterUrl, width: 60, height: 90, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(width: 60, height: 90, color: Colors.white10)),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Current Trailer: ${!hasTrailer ? "None" : "Uploaded"}', 
                      style: TextStyle(color: !hasTrailer ? Colors.orange : Colors.green, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  if (hasTrailer)
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
                      onPressed: () => _previewTrailer(movie.trailerPlaybackUrl!),
                      tooltip: 'Preview Trailer',
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _uploadTrailer(movie),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: const Text('REPLACE / UPLOAD'),
                    style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _uploadTrailer(AdminMovieEntity movie) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Manage Trailer: ${movie.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 32),
              VideoPickerWidget(
                label: 'Select Video File (MP4/MOV)',
                onVideoSelected: (fileData) {
                  if (fileData != null) {
                    context.read<MovieUploadProvider>().startFullUpload(
                      movie: movie,
                      posterFile: null,
                      bannerFile: null,
                      trailerFile: fileData,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _previewTrailer(String url) {
    // Integration with a web video player or external link
  }
}
