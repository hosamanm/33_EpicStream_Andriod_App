import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity_log_entity.dart';

class ActivityLogModel extends ActivityLogEntity {
  const ActivityLogModel({
    required super.id,
    required super.adminId,
    required super.adminEmail,
    required super.action,
    required super.module,
    required super.targetId,
    required super.description,
    super.metadata,
    required super.ipAddress,
    required super.timestamp,
  });

  factory ActivityLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityLogModel(
      id: doc.id,
      adminId: data['adminId'] ?? '',
      adminEmail: data['adminEmail'] ?? '',
      action: ActivityAction.values.firstWhere(
        (e) => e.name == data['action'],
        orElse: () => ActivityAction.systemError,
      ),
      module: ActivityModule.values.firstWhere(
        (e) => e.name == data['module'],
        orElse: () => ActivityModule.system,
      ),
      targetId: data['targetId'] ?? '',
      description: data['description'] ?? '',
      metadata: data['metadata'],
      ipAddress: data['ipAddress'] ?? '0.0.0.0',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'adminId': adminId,
      'adminEmail': adminEmail,
      'action': action.name,
      'module': module.name,
      'targetId': targetId,
      'description': description,
      'metadata': metadata,
      'ipAddress': ipAddress,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
