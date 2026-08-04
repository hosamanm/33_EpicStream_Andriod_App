import 'package:equatable/equatable.dart';

enum AdminNotificationType { movieRelease, offer, breakingNews, liveEvent, custom }
enum AdminNotificationTarget { all, free, selected, language, country }
enum AdminNotificationScheduleType { immediate, scheduled, recurring }
enum AdminNotificationStatus { pending, sending, sent, failed }

class AdminNotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final AdminNotificationType type;
  final AdminNotificationTarget target;
  final List<String>? targetValues; // List of UIDs, language codes, or country names
  final AdminNotificationScheduleType scheduleType;
  final DateTime? scheduledFor;
  final String? deepLinkType; // 'movie', 'category'
  final String? deepLinkValue; // ID of movie or category
  final AdminNotificationStatus status;
  final int sentCount;
  final int openedCount;
  final DateTime createdAt;

  const AdminNotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    required this.target,
    this.targetValues,
    required this.scheduleType,
    this.scheduledFor,
    this.deepLinkType,
    this.deepLinkValue,
    this.status = AdminNotificationStatus.pending,
    this.sentCount = 0,
    this.openedCount = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, type, target, status, scheduledFor];

  AdminNotificationEntity copyWith({
    AdminNotificationStatus? status,
    int? sentCount,
    int? openedCount,
  }) {
    return AdminNotificationEntity(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: type,
      target: target,
      targetValues: targetValues,
      scheduleType: scheduleType,
      scheduledFor: scheduledFor,
      deepLinkType: deepLinkType,
      deepLinkValue: deepLinkValue,
      status: status ?? this.status,
      sentCount: sentCount ?? this.sentCount,
      openedCount: openedCount ?? this.openedCount,
      createdAt: createdAt,
    );
  }
}
