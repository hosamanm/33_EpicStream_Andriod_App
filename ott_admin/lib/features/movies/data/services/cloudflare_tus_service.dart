import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CloudflareTusService {
  final Dio _dio;
  final Logger _logger;
  
  // These should ideally be in a secure config or environment variables
  static const String _accountId = 'customer-vdyo74k9rxtpx760';
  static const String _apiToken = 'YOUR_CLOUDFLARE_API_TOKEN';

  CloudflareTusService(this._dio, this._logger);

  Future<String> initializeResumableUpload({
    required int size,
    required String title,
    Map<String, String>? metadata,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.cloudflare.com/client/v4/accounts/$_accountId/stream',
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Tus-Resumable': '1.0.0',
            'Upload-Length': '$size',
            'Upload-Metadata': _encodeMetadata({'name': title, ...?metadata}),
          },
        ),
      );

      final uploadUrl = response.headers.value('location');
      if (uploadUrl == null) throw Exception('Cloudflare did not return an upload URL');
      return uploadUrl;
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _logger.w('Cloudflare TUS Init Cancelled');
      } else {
        _logger.e('Cloudflare TUS Init Failed', error: e);
      }
      rethrow;
    }
  }

  Future<void> uploadData({
    required String url,
    required Uint8List data,
    required Function(double) onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.patch(
        url,
        data: Stream.fromIterable(data.map((e) => [e])),
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Tus-Resumable': '1.0.0',
            'Upload-Offset': '0',
            'Content-Type': 'application/offset+octet-stream',
          },
        ),
        onSendProgress: (sent, total) {
          if (total > 0) onProgress(sent / total);
        },
      );
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        _logger.w('Cloudflare TUS Upload Cancelled');
      } else {
        _logger.e('Cloudflare TUS Patch Failed', error: e);
      }
      rethrow;
    }
  }

  String _encodeMetadata(Map<String, String> metadata) {
    return metadata.entries
        .map((e) => '${e.key} ${base64Encode(utf8.encode(e.value))}')
        .join(',');
  }

  Future<void> deleteVideo(String videoId) async {
    try {
      await _dio.delete(
        'https://api.cloudflare.com/client/v4/accounts/$_accountId/stream/$videoId',
        options: Options(headers: {'Authorization': 'Bearer $_apiToken'}),
      );
    } catch (e) {
      _logger.e('Failed to delete Cloudflare video $videoId', error: e);
    }
  }
}
