import 'package:equatable/equatable.dart';

enum VideoType { hls, mp4, dash }

class VideoSourceEntity extends Equatable {
  final String id;
  final String title;
  final String url;
  final VideoType type;
  final String? subtitleUrl;
  final String? thumbnailUrl;
  final Map<String, String>? headers;

  const VideoSourceEntity({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.subtitleUrl,
    this.thumbnailUrl,
    this.headers,
  });

  @override
  List<Object?> get props => [id, title, url, type, subtitleUrl, thumbnailUrl, headers];
}
