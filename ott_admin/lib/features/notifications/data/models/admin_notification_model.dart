import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_notification_entity.dart';

class AdminNotificationModel extends AdminNotificationEntity {
  const AdminNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    super.imageUrl,
    required super.type,
    required super.target,
    super.targetValues,
    required super.scheduleType,
    super.scheduledFor,
    super.deepLinkType,
    super.deepLinkValue,
    super.status,
    super.sentCount,
    super.openedCount,
    required super.createdAt,
  });

  factory AdminNotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminNotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      type: AdminNotificationType.values.firstWhere((e) => e.name == data['type']),
      target: AdminNotificationTarget.values.firstWhere((e) => e.name == data['target']),
      targetValues: data['targetValues'] != null ? List<String>.from(data['targetValues']) : null,
      scheduleType: AdminNotificationScheduleType.values.firstWhere((e) => e.name == data['scheduleType']),
      scheduledFor: (data['scheduledFor'] as Timestamp?)?.toDate(),
      deepLinkType: data['deepLinkType'],
      deepLinkValue: data['deepLinkValue'],
      status: AdminNotificationStatus.values.firstWhere((e) => e.name == (data['status'] ?? 'pending')),
      sentCount: data['sentCount'] ?? 0,
      openedCount: data['openedCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'type': type.name,
      'target': target.name,
      'targetValues': targetValues,
      'scheduleType': scheduleType.name,
      'scheduledFor': scheduledFor != null ? Timestamp.fromDate(scheduledFor!) : null,
      'deepLinkType': deepLinkType,
      'deepLinkValue': deepLinkValue,
      'status': status.name,
      'sentCount': sentCount,
      'openedCount': openedCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
