import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_history_entity.dart';

class NotificationHistoryModel extends NotificationHistoryEntity {
  const NotificationHistoryModel({
    required super.id,
    required super.userId,
    required super.notificationId,
    super.isRead = false,
    super.readAt,
    super.clickedAt,
    required super.title,
    required super.body,
    super.imageUrl,
    required super.type,
    super.movieId,
    super.deepLink,
    required super.createdAt,
  });

  factory NotificationHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationHistoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      notificationId: data['notificationId'] ?? '',
      isRead: data['isRead'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      clickedAt: (data['clickedAt'] as Timestamp?)?.toDate(),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      type: data['type'] ?? 'custom',
      movieId: data['movieId'],
      deepLink: data['deepLink'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'notificationId': notificationId,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'clickedAt': clickedAt != null ? Timestamp.fromDate(clickedAt!) : null,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': type,
      'movieId': movieId,
      'deepLink': deepLink,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
