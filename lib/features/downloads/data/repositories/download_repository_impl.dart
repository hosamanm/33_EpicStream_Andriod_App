import '../../domain/entities/download_item.dart';
import '../../domain/repositories/download_repository.dart';
import '../datasources/download_local_datasource.dart';
import '../models/download_model.dart';

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadLocalDataSource _localDataSource;

  DownloadRepositoryImpl(this._localDataSource);

  @override
  Future<List<DownloadItem>> getDownloads() async {
    return await _localDataSource.getDownloads();
  }

  @override
  Future<void> saveDownload(DownloadItem item) async {
    await _localDataSource.saveDownload(DownloadModel(
      id: item.id,
      title: item.title,
      posterUrl: item.posterUrl,
      localPath: item.localPath,
      remoteUrl: item.remoteUrl,
      sizeBytes: item.sizeBytes,
      downloadedBytes: item.downloadedBytes,
      status: item.status,
      quality: item.quality,
    ));
  }

  @override
  Future<void> updateDownloadStatus(String id, DownloadStatus status) async {
    final downloads = await _localDataSource.getDownloads();
    final index = downloads.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = downloads[index].copyWith(status: status);
      await _localDataSource.updateDownload(updated as DownloadModel);
    }
  }

  @override
  Future<void> updateDownloadProgress(String id, int downloadedBytes, int sizeBytes) async {
    final downloads = await _localDataSource.getDownloads();
    final index = downloads.indexWhere((e) => e.id == id);
    if (index != -1) {
      final updated = downloads[index].copyWith(
        downloadedBytes: downloadedBytes,
        sizeBytes: sizeBytes,
      );
      await _localDataSource.updateDownload(updated as DownloadModel);
    }
  }

  @override
  Future<void> deleteDownload(String id) async {
    await _localDataSource.deleteDownload(id);
  }
}
