import '../entities/download_item.dart';

abstract class DownloadRepository {
  Future<List<DownloadItem>> getDownloads();
  Future<void> saveDownload(DownloadItem item);
  Future<void> updateDownloadStatus(String id, DownloadStatus status);
  Future<void> updateDownloadProgress(String id, int downloadedBytes, int sizeBytes);
  Future<void> deleteDownload(String id);
}
