import 'package:flutter/material.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../../data/services/download_service.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadRepository _repository;
  final DownloadService _downloadService;

  DownloadProvider(this._repository, this._downloadService);

  List<DownloadItem> _items = [];
  List<DownloadItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadDownloads() async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getDownloads();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> startDownload(DownloadItem item) async {
    // Add to local registry first
    await _repository.saveDownload(item);
    await loadDownloads();

    // Start background task via service
    try {
      await _downloadService.startDownload(
        item,
        onProgress: (received, total) {
          updateProgress(item.id, received, total);
        },
      );
      await loadDownloads(); // Refresh to show 'completed'
    } catch (e) {
      debugPrint('Download Error: $e');
      setStatus(item.id, DownloadStatus.error);
    }
  }

  Future<void> removeDownload(String id) async {
    final item = _items.firstWhere((e) => e.id == id);
    _downloadService.cancelDownload(id);
    await _downloadService.deleteDownloadedFile(item.localPath);
    await _repository.deleteDownload(id);
    await loadDownloads();
  }

  void updateProgress(String id, int downloadedBytes, int sizeBytes) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(
        downloadedBytes: downloadedBytes,
        sizeBytes: sizeBytes,
        status: DownloadStatus.downloading,
      );
      notifyListeners();
    }
  }

  void setStatus(String id, DownloadStatus status) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(status: status);
      notifyListeners();
      _repository.updateDownloadStatus(id, status);
    }
  }
}
