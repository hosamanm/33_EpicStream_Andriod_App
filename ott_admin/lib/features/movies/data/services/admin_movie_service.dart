import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_movie_model.dart';
import 'firebase_storage_service.dart';
import 'cloudflare_tus_service.dart';

class AdminMovieService {
  final FirebaseFirestore _firestore;
  final FirebaseStorageService _storageService;
  final CloudflareTusService _cloudflareService;

  AdminMovieService(this._firestore, this._storageService, this._cloudflareService);

  Future<List<AdminMovieModel>> fetchMovies({int limit = 20}) async {
    final snapshot = await _firestore.collection('movies')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => AdminMovieModel.fromFirestore(doc)).toList();
  }

  Future<AdminMovieModel?> fetchMovieById(String id) async {
    final doc = await _firestore.collection('movies').doc(id).get();
    if (!doc.exists) return null;
    return AdminMovieModel.fromFirestore(doc);
  }

  /// Saves a movie to Firestore. Returns the document ID.
  Future<String> saveMovie(AdminMovieModel movie) async {
    final docRef = movie.id.isEmpty 
        ? _firestore.collection('movies').doc() 
        : _firestore.collection('movies').doc(movie.id);
    
    await docRef.set(movie.toFirestore(), SetOptions(merge: true));
    return docRef.id;
  }

  /// Performs a deep delete: Firestore Metadata + Firebase Storage Assets + Cloudflare Videos
  Future<void> deleteMovie(AdminMovieModel movie) async {
    // 1. Delete Cloudflare Videos
    if (movie.movieVideoId != null) await _cloudflareService.deleteVideo(movie.movieVideoId!);
    if (movie.trailerVideoId != null) await _cloudflareService.deleteVideo(movie.trailerVideoId!);

    // 2. Delete Firebase Storage Files
    await _storageService.deleteFile('movies/posters/${movie.id}.jpg');
    await _storageService.deleteFile('movies/banners/${movie.id}.jpg');
    if (movie.logoUrl != null) await _storageService.deleteFile('movies/logos/${movie.id}.png');
    if (movie.thumbnailUrl != null) await _storageService.deleteFile('movies/thumbnails/${movie.id}.jpg');
    
    // Delete Subtitles Folder
    await _storageService.deleteFolder('movies/subtitles/${movie.id}');

    // 3. Delete Firestore Document
    await _firestore.collection('movies').doc(movie.id).delete();
  }

  Future<void> updateMovieStatus(String id, String status) async {
    await _firestore.collection('movies').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
