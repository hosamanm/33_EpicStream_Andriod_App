import 'package:equatable/equatable.dart';

enum ContentStatus { draft, published, archived }
enum ContentType { movie, series }

class ContentItemEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final String bannerUrl;
  final ContentType type;
  final ContentStatus status;
  final DateTime createdAt;
  final String categoryId;
  final double rating;

  const ContentItemEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.bannerUrl,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.categoryId,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, title, status, type];
}
