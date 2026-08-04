import 'package:equatable/equatable.dart';

enum ActivityAction {
  login, logout, upload, edit, delete, publish, unpublish, 
  userBlock, userUnblock, notify, systemError, securityAlert
}

enum ActivityModule {
  auth, movies, users, categories, banners, notifications, settings, system
}

class ActivityLogEntity extends Equatable {
  final String id;
  final String adminId;
  final String adminEmail;
  final ActivityAction action;
  final ActivityModule module;
  final String targetId;
  final String description;
  final Map<String, dynamic>? metadata;
  final String ipAddress;
  final DateTime timestamp;

  const ActivityLogEntity({
    required this.id,
    required this.adminId,
    required this.adminEmail,
    required this.action,
    required this.module,
    required this.targetId,
    required this.description,
    this.metadata,
    required this.ipAddress,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, adminId, action, targetId, timestamp];
}
