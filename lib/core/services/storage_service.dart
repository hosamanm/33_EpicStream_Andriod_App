import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

/// Production-grade service for Firebase Storage operations.
class StorageService {
  final FirebaseStorage _storage;

  StorageService(this._storage);

  /// Uploads a file to a specific path and returns the download URL.
  Future<String> uploadFile({
    required File file,
    required String folder,
    required String fileName,
  }) async {
    try {
      final extension = path.extension(file.path);
      final ref = _storage.ref().child('$folder/$fileName$extension');
      
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/${extension.replaceFirst('.', '')}'),
      );
      
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: ${e.toString()}');
    }
  }

  /// Deletes a file from storage.
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Log error but don't block
    }
  }
}
