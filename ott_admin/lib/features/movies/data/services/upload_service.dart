import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../models/admin_movie_model.dart';
import 'firebase_storage_service.dart';
import 'admin_movie_service.dart';
import 'cloudflare_tus_service.dart';

/// Centralized service to handle the orchestration of movie asset uploads.
/// Manages Firebase Storage for images/subtitles and Cloudflare Stream for video via TUS.
class UploadService {
  final FirebaseStorageService _storageService;
  final CloudflareTusService _cloudflareService;
  final AdminMovieService _movieService;
  final FirebaseFirestore _firestore;

  UploadService(
    this._storageService, 
    this._cloudflareService, 
    this._movieService,
    this._firestore,
  );

  Future<void> uploadMovie({
    required AdminMovieEntity movie,
    Uint8List? posterFile,
    Uint8List? bannerFile,
    Uint8List? logoFile,
    Uint8List? thumbnailFile,
    Uint8List? trailerFile,
    Uint8List? videoFile,
    List<Uint8List>? subtitleFiles,
    required Function(String task, double progress) onProgress,
  }) async {
    // 1. Duplicate Detection (Pre-flight check)
    if (movie.id.isEmpty) {
      final existing = await _firestore.collection('movies')
          .where('title', isEqualTo: movie.title)
          .where('releaseDate', isEqualTo: movie.releaseDate)
          .get();
      if (existing.docs.isNotEmpty) {
        throw Exception('Duplicate Entry: A movie with this title and release date already exists.');
      }
    }

    final String movieId = movie.id.isEmpty 
        ? 'movie_${DateTime.now().millisecondsSinceEpoch}' 
        : movie.id;

    String posterUrl = movie.posterUrl;
    String bannerUrl = movie.bannerUrl;
    String? logoUrl = movie.logoUrl;
    String? thumbnailUrl = movie.thumbnailUrl;
    String? trailerVideoId = movie.trailerVideoId;
    String? movieVideoId = movie.movieVideoId;
    List<String> subtitleUrls = List.from(movie.subtitleUrls);

    // 2. Parallel Firebase Storage Uploads (Images)
    final List<Future> imageUploadTasks = [];

    if (posterFile != null) {
      imageUploadTasks.add(_storageService.uploadFile(
        path: 'movies/posters/$movieId.jpg',
        file: posterFile,
        onProgress: (p) => onProgress('Poster', p),
      ).then((url) => posterUrl = url));
    }
    if (bannerFile != null) {
      imageUploadTasks.add(_storageService.uploadFile(
        path: 'movies/banners/$movieId.jpg',
        file: bannerFile,
        onProgress: (p) => onProgress('Banner', p),
      ).then((url) => bannerUrl = url));
    }
    if (logoFile != null) {
      imageUploadTasks.add(_storageService.uploadFile(
        path: 'movies/logos/$movieId.png',
        file: logoFile,
        onProgress: (p) => onProgress('Logo', p),
      ).then((url) => logoUrl = url));
    }
    if (thumbnailFile != null) {
      imageUploadTasks.add(_storageService.uploadFile(
        path: 'movies/thumbnails/$movieId.jpg',
        file: thumbnailFile,
        onProgress: (p) => onProgress('Thumbnail', p),
      ).then((url) => thumbnailUrl = url));
    }

    await Future.wait(imageUploadTasks);

    // 3. Sequential Uploads (Subtitles)
    if (subtitleFiles != null) {
      subtitleUrls.clear(); // If replacing, we start fresh or append depending on requirements.
      for (int i = 0; i < subtitleFiles.length; i++) {
        final url = await _storageService.uploadFile(
          path: 'movies/subtitles/$movieId/lang_$i.vtt',
          file: subtitleFiles[i],
          onProgress: (p) => onProgress('Subtitle ${i + 1}', p),
        );
        subtitleUrls.add(url);
      }
    }

    // 4. Cloudflare Stream - TUS Resumable Uploads
    if (trailerFile != null) {
      onProgress('Trailer Initialization', 0.0);
      final tusUrl = await _cloudflareService.initializeResumableUpload(
        size: trailerFile.length,
        title: '${movie.title} (Trailer)',
      );
      await _cloudflareService.uploadData(
        url: tusUrl,
        data: trailerFile,
        onProgress: (p) => onProgress('Trailer Video', p),
      );
      trailerVideoId = tusUrl.split('/').last;
    }

    if (videoFile != null) {
      onProgress('Movie Initialization', 0.0);
      final tusUrl = await _cloudflareService.initializeResumableUpload(
        size: videoFile.length,
        title: movie.title,
      );
      await _cloudflareService.uploadData(
        url: tusUrl,
        data: videoFile,
        onProgress: (p) => onProgress('Full Movie Video', p),
      );
      movieVideoId = tusUrl.split('/').last;
    }

    // 5. Final Firestore Sync
    final model = AdminMovieModel(
      id: movieId,
      title: movie.title,
      originalTitle: movie.originalTitle,
      description: movie.description,
      shortDescription: movie.shortDescription,
      posterUrl: posterUrl,
      bannerUrl: bannerUrl,
      logoUrl: logoUrl,
      thumbnailUrl: thumbnailUrl,
      trailerVideoId: trailerVideoId,
      trailerPlaybackUrl: trailerVideoId != null ? 'https://customer-vdyo74k9rxtpx760.cloudflarestream.com/$trailerVideoId/watch' : null,
      movieVideoId: movieVideoId,
      moviePlaybackUrl: movieVideoId != null ? 'https://customer-vdyo74k9rxtpx760.cloudflarestream.com/$movieVideoId/watch' : null,
      subtitleUrls: subtitleUrls,
      genreIds: movie.genreIds,
      categoryIds: movie.categoryIds,
      language: movie.language,
      country: movie.country,
      cast: movie.cast,
      crew: movie.crew,
      director: movie.director,
      producer: movie.producer,
      writer: movie.writer,
      musicDirector: movie.musicDirector,
      duration: movie.duration,
      releaseDate: movie.releaseDate,
      ageRating: movie.ageRating,
      imdbRating: movie.imdbRating,
      status: movie.status,
      isFeatured: movie.isFeatured,
      isTrending: movie.isTrending,
      isEditorsChoice: movie.isEditorsChoice,
      createdAt: movie.id.isEmpty ? DateTime.now() : movie.createdAt,
      updatedAt: DateTime.now(),
    );

    await _movieService.saveMovie(model);
  }
}
