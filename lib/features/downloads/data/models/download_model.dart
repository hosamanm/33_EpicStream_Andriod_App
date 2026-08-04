import '../../domain/entities/download_item.dart';

class DownloadModel extends DownloadItem {
  const DownloadModel({
    required super.id,
    required super.title,
    required super.posterUrl,
    required super.localPath,
    required super.remoteUrl,
    super.sizeBytes,
    super.downloadedBytes,
    super.status,
    super.quality,
  });

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
      id: json['id'],
      title: json['title'],
      posterUrl: json['posterUrl'],
      localPath: json['localPath'],
      remoteUrl: json['remoteUrl'],
      sizeBytes: json['sizeBytes'] ?? 0,
      downloadedBytes: json['downloadedBytes'] ?? 0,
      status: DownloadStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DownloadStatus.queued,
      ),
      quality: json['quality'] ?? '720p',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'posterUrl': posterUrl,
      'localPath': localPath,
      'remoteUrl': remoteUrl,
      'sizeBytes': sizeBytes,
      'downloadedBytes': downloadedBytes,
      'status': status.toString(),
      'quality': quality,
    };
  }
}
