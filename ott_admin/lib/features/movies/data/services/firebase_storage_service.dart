import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Service responsible for raw file uploads to Firebase Storage.
/// Handles progress tracking and provides download URLs.
class FirebaseStorageService {
  final FirebaseStorage _storage;
  final Logger _logger;

  FirebaseStorageService(this._storage, this._logger);

  /// Uploads a file and returns its download URL.
  /// [path] is the destination path in Storage (e.g., 'movies/posters/movie_id.jpg').
  /// [file] can be a File (Mobile/Desktop) or Uint8List (Web).
  Future<String> uploadFile({
    required String path,
    required dynamic file,
    required Function(double) onProgress,
  }) async {
    try {
      UploadTask task;
      
      if (kIsWeb) {
        if (file is! Uint8List) throw Exception('Web uploads require Uint8List');
        task = _storage.ref().child(path).putData(file);
      } else {
        if (file is! File) throw Exception('Mobile/Desktop uploads require File object');
        task = _storage.ref().child(path).putFile(file);
      }

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      final snapshot = await task;
      final url = await snapshot.ref.getDownloadURL();
      _logger.i('File uploaded successfully to $path');
      return url;
    } catch (e) {
      _logger.e('FirebaseStorageService: Upload failed at $path', error: e);
      rethrow;
    }
  }

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e) {
      _logger.e('FirebaseStorageService: Deletion failed at $path', error: e);
    }
  }

  /// Deletes all files under a specific prefix (folder simulation).
  Future<void> deleteFolder(String path) async {
    try {
      final listResult = await _storage.ref().child(path).listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
      for (var prefix in listResult.prefixes) {
        await deleteFolder(prefix.fullPath);
      }
    } catch (e) {
      _logger.e('FirebaseStorageService: Folder deletion failed at $path', error: e);
    }
  }
}
