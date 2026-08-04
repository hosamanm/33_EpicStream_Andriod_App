import 'package:dio/dio.dart';
import '../../../../core/config/admin_config.dart';

class CloudflareService {
  final Dio _dio;
  final String _accountId = 'customer-vdyo74k9rxtpx760'; // Your Cloudflare ID
  final String _apiToken = 'YOUR_CLOUDFLARE_API_TOKEN';

  CloudflareService(this._dio);

  /// Requests an upload URL from Cloudflare Stream
  Future<Map<String, dynamic>> createDirectUpload({
    required int size,
    required String title,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.cloudflare.com/client/v4/accounts/$_accountId/stream/direct_upload',
        data: {
          'maxDurationSeconds': 3600 * 4, // 4 hours max
          'expiry': DateTime.now().add(const Duration(hours: 6)).toIso8601String(),
          'meta': {'name': title},
        },
        options: Options(headers: {'Authorization': 'Bearer $_apiToken'}),
      );

      return response.data['result'];
    } catch (e) {
      throw Exception('Cloudflare Upload Request Failed: ${e.toString()}');
    }
  }

  /// Fetches video status (encoding progress)
  Future<String> getVideoStatus(String videoId) async {
    try {
      final response = await _dio.get(
        'https://api.cloudflare.com/client/v4/accounts/$_accountId/stream/$videoId',
        options: Options(headers: {'Authorization': 'Bearer $_apiToken'}),
      );
      return response.data['result']['status']['state'];
    } catch (e) {
      return 'unknown';
    }
  }

  /// Deletes a video from Cloudflare
  Future<void> deleteVideo(String videoId) async {
    await _dio.delete(
      'https://api.cloudflare.com/client/v4/accounts/$_accountId/stream/$videoId',
      options: Options(headers: {'Authorization': 'Bearer $_apiToken'}),
    );
  }
}
