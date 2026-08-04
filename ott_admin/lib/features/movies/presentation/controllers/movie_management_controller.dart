import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../providers/movie_provider.dart';
import '../providers/movie_upload_provider.dart';
import '../widgets/movie_dialog.dart';
import '../widgets/upload_progress_dialog.dart';

class MovieManagementController {
  final AdminMovieProvider _movieProvider;

  MovieManagementController(this._movieProvider);

  void onSearchChanged(String query) {
    _movieProvider.setSearchQuery(query);
  }

  void onAddMovie(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MovieDialog(
        onSave: ({
          required movie,
          poster,
          banner,
          logo,
          thumbnail,
          video,
          trailer,
          subtitles,
        }) =>
            _handleSave(
          context,
          movie: movie,
          poster: poster,
          banner: banner,
          logo: logo,
          thumbnail: thumbnail,
          video: video,
          trailer: trailer,
          subtitles: subtitles,
        ),
      ),
    );
  }

  void onEditMovie(BuildContext context, AdminMovieEntity movie) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MovieDialog(
        movie: movie,
        onSave: ({
          required movie,
          poster,
          banner,
          logo,
          thumbnail,
          video,
          trailer,
          subtitles,
        }) =>
            _handleSave(
          context,
          movie: movie,
          poster: poster,
          banner: banner,
          logo: logo,
          thumbnail: thumbnail,
          video: video,
          trailer: trailer,
          subtitles: subtitles,
        ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context, {
    required AdminMovieEntity movie,
    Uint8List? poster,
    Uint8List? banner,
    Uint8List? logo,
    Uint8List? thumbnail,
    Uint8List? video,
    Uint8List? trailer,
    List<Uint8List>? subtitles,
  }) async {
    // 1. Close Form Dialog
    Navigator.pop(context);

    // 2. Open Progress Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UploadProgressDialog(),
    );

    try {
      // 3. Start Multi-Track Upload
      await context.read<MovieUploadProvider>().startFullUpload(
            movie: movie,
            posterFile: poster,
            bannerFile: banner,
            logoFile: logo,
            thumbnailFile: thumbnail,
            videoFile: video,
            trailerFile: trailer,
            subtitleFiles: subtitles,
          );

      // 4. Refresh List & Close Progress
      if (context.mounted) {
        Navigator.pop(context);
        _movieProvider.fetchMovies(isRefresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Movie saved and uploaded successfully!'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _showError(context, e.toString());
      }
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Upload Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> onDeleteMovie(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Movie'),
        content: const Text(
            'Are you sure? This will remove the Firestore document. Note: Cloudflare and Storage assets must be cleaned manually or via Cloud Function.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('DELETE', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await _movieProvider.deleteMovie(id);
    }
  }

  Future<void> togglePublish(String id, bool publish) async {
    await _movieProvider.togglePublish(id, publish);
  }

  Future<void> onBulkPublish(BuildContext context, List<String> ids, bool publish) async {
    for (final id in ids) {
      await _movieProvider.togglePublish(id, publish);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected items ${publish ? 'published' : 'unpublished'}')),
      );
    }
  }

  Future<void> onBulkDelete(BuildContext context, List<String> ids) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${ids.length} Movies'),
        content: const Text('Are you sure you want to delete all selected movies? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE ALL', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      for (final id in ids) {
        await _movieProvider.deleteMovie(id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected movies deleted')),
        );
      }
    }
  }
}
