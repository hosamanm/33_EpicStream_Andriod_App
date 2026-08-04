import '../../domain/entities/video_source_entity.dart';

class VideoSourceModel extends VideoSourceEntity {
  const VideoSourceModel({
    required super.id,
    required super.title,
    required super.url,
    required String type,
    super.subtitleUrl,
    super.thumbnailUrl,
    super.headers,
  }) : super(
          type: type == 'hls' ? VideoType.hls : VideoType.mp4,
        );

  factory VideoSourceModel.fromJson(Map<String, dynamic> json) {
    return VideoSourceModel(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      type: json['type'],
      subtitleUrl: json['subtitleUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      headers: json['headers'] != null ? Map<String, String>.from(json['headers']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'type': type == VideoType.hls ? 'hls' : 'mp4',
      'subtitleUrl': subtitleUrl,
      'thumbnailUrl': thumbnailUrl,
      'headers': headers,
    };
  }
}
