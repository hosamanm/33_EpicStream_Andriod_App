import 'package:equatable/equatable.dart';

class NotificationHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String notificationId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? clickedAt;
  
  // Denormalized data for UI efficiency
  final String title;
  final String body;
  final String? imageUrl;
  final String type;
  final String? movieId;
  final String? deepLink;
  final DateTime createdAt;

  const NotificationHistoryEntity({
    required this.id,
    required this.userId,
    required this.notificationId,
    this.isRead = false,
    this.readAt,
    this.clickedAt,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    this.movieId,
    this.deepLink,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, notificationId, isRead];
}
