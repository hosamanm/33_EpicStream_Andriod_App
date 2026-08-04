import 'package:equatable/equatable.dart';

enum AdminRole { superAdmin, admin, editor, moderator, viewer }

class AdminEntity extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final bool isAdmin;
  final AdminRole role;

  const AdminEntity({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.isAdmin,
    this.role = AdminRole.viewer,
  });

  // Granular Permission Matrix
  bool get isSuperAdmin => role == AdminRole.superAdmin;
  
  bool get canManageSettings => role == AdminRole.superAdmin;
  
  bool get canManageUsers => role == AdminRole.superAdmin || role == AdminRole.admin;
  
  bool get canManageContent => role == AdminRole.superAdmin || 
                               role == AdminRole.admin || 
                               role == AdminRole.editor;
                               
  bool get canManageMetadata => role == AdminRole.superAdmin || 
                                role == AdminRole.admin || 
                                role == AdminRole.editor || 
                                role == AdminRole.moderator;

  bool get canSendNotifications => role == AdminRole.superAdmin || 
                                   role == AdminRole.admin || 
                                   role == AdminRole.moderator;

  bool get canViewReports => true; // All roles can view basic analytics

  @override
  List<Object?> get props => [uid, email, fullName, isAdmin, role];
}
