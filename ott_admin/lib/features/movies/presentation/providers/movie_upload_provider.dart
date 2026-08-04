import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../../data/services/upload_service.dart';

class MovieUploadProvider extends ChangeNotifier {
  final UploadService _uploadService;

  MovieUploadProvider(this._uploadService);

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  Map<String, double> _progressMap = {};
  Map<String, double> get progressMap => _progressMap;

  String? _currentTask;
  String? get currentTask => _currentTask;

  String? _error;
  String? get error => _error;

  void _updateProgress(String task, double progress) {
    _currentTask = task;
    _progressMap[task] = progress;
    notifyListeners();
  }

  Future<void> startFullUpload({
    required AdminMovieEntity movie,
    Uint8List? posterFile,
    Uint8List? bannerFile,
    Uint8List? logoFile,
    Uint8List? thumbnailFile,
    Uint8List? trailerFile,
    Uint8List? videoFile,
    List<Uint8List>? subtitleFiles,
  }) async {
    _isUploading = true;
    _progressMap = {};
    _error = null;
    notifyListeners();

    try {
      await _uploadService.uploadMovie(
        movie: movie,
        posterFile: posterFile,
        bannerFile: bannerFile,
        logoFile: logoFile,
        thumbnailFile: thumbnailFile,
        trailerFile: trailerFile,
        videoFile: videoFile,
        subtitleFiles: subtitleFiles,
        onProgress: _updateProgress,
      );
      _isUploading = false;
      notifyListeners();
    } catch (e) {
      _isUploading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void reset() {
    _isUploading = false;
    _progressMap = {};
    _currentTask = null;
    _error = null;
    notifyListeners();
  }
}
