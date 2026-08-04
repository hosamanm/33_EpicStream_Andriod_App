import 'package:equatable/equatable.dart';

enum DownloadStatus { queued, downloading, paused, completed, error }

class DownloadItem extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final String localPath;
  final String remoteUrl;
  final int sizeBytes;
  final int downloadedBytes;
  final DownloadStatus status;
  final String quality;

  const DownloadItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.localPath,
    required this.remoteUrl,
    this.sizeBytes = 0,
    this.downloadedBytes = 0,
    this.status = DownloadStatus.queued,
    this.quality = '720p',
  });

  double get progress => sizeBytes > 0 ? downloadedBytes / sizeBytes : 0;

  DownloadItem copyWith({
    DownloadStatus? status,
    int? downloadedBytes,
    int? sizeBytes,
    String? localPath,
  }) {
    return DownloadItem(
      id: id,
      title: title,
      posterUrl: posterUrl,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      quality: quality,
    );
  }

  @override
  List<Object?> get props => [id, status, downloadedBytes, sizeBytes];
}
