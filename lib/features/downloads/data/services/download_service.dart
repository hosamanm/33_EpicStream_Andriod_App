import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/download_model.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';

class DownloadService {
  final Dio _dio;
  final DownloadRepository _repository;
  final Map<String, CancelToken> _activeTasks = {};

  DownloadService(this._dio, this._repository);

  Future<void> startDownload(DownloadItem item, {Function(int, int)? onProgress}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/downloads/${item.id}_${item.quality}.mp4';
      
      // Ensure directory exists
      final file = File(savePath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }

      final cancelToken = CancelToken();
      _activeTasks[item.id] = cancelToken;

      await _repository.updateDownloadStatus(item.id, DownloadStatus.downloading);

      await _dio.download(
        item.remoteUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress?.call(received, total);
            _repository.updateDownloadProgress(item.id, received, total);
          }
        },
      );

      await _repository.updateDownloadStatus(item.id, DownloadStatus.completed);
      _activeTasks.remove(item.id);
    } catch (e) {
      if (!CancelToken.isCancel(e as DioException)) {
        await _repository.updateDownloadStatus(item.id, DownloadStatus.error);
      }
      _activeTasks.remove(item.id);
      rethrow;
    }
  }

  void cancelDownload(String id) {
    _activeTasks[id]?.cancel();
    _activeTasks.remove(id);
    _repository.updateDownloadStatus(id, DownloadStatus.paused);
  }

  Future<void> deleteDownloadedFile(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
