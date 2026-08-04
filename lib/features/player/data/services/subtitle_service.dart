import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service to handle external subtitle operations like downloading and local caching.
class SubtitleService {
  final Dio _dio;

  SubtitleService(this._dio);

  /// Downloads an external subtitle file and returns the local path.
  /// Useful for supporting offline playback or side-loaded subtitles.
  Future<String?> downloadSubtitle(String url, String movieId, String lang) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/subtitles/${movieId}_$lang.vtt';
      
      final file = File(filePath);
      if (await file.exists()) return filePath;

      await _dio.download(url, filePath);
      return filePath;
    } catch (e) {
      // In production, log this to Crashlytics
      return null;
    }
  }
}
