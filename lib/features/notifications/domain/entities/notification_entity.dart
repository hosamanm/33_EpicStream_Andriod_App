import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String type; // 'new_movie', 'trailer', 'featured', 'announcement', 'maintenance', 'custom'
  final String? movieId;
  final String? deepLink;
  final bool isActive;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    this.movieId,
    this.deepLink,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, type, movieId];
}
