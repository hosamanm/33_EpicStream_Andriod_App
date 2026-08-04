import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/entities/admin_user_page.dart';
import '../../domain/repositories/admin_user_repository.dart';
import '../models/admin_user_model.dart';
import '../services/admin_user_service.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserService _service;
  final ActivityLogRepository _logRepository;
  final FirebaseAuth _auth;

  AdminUserRepositoryImpl(this._service, this._logRepository, this._auth);

  String get _adminEmail => _auth.currentUser?.email ?? 'system';
  String get _adminId => _auth.currentUser?.uid ?? 'system';

  @override
  Future<Result<AdminUserPage>> getUsers({int limit = 20, DocumentSnapshot? lastDoc}) async {
    try {
      final snapshot = await _service.fetchUsersSnapshot(limit: limit, startAfter: lastDoc);
      final users = snapshot.docs.map((doc) => AdminUserModel.fromFirestore(doc)).toList();
      final lastSnapshot = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      
      return Result.success(AdminUserPage(
        users: users,
        lastDoc: lastSnapshot,
      ));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateUserStatus(String uid, {required bool isBlocked}) async {
    try {
      await _service.updateUserField(uid, {
        'isBlocked': isBlocked,
        'status': isBlocked ? 'blocked' : 'active',
      });

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: isBlocked ? ActivityAction.userBlock : ActivityAction.userUnblock,
        module: ActivityModule.users,
        targetId: uid,
        description: '${isBlocked ? 'Blocked' : 'Unblocked'} user ID: $uid',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteUser(String uid) async {
    try {
      await _service.deleteUser(uid);

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: ActivityAction.delete,
        module: ActivityModule.users,
        targetId: uid,
        description: 'Deleted user ID: $uid',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUserLibrary(String uid) async {
    try {
      final library = await _service.getUserLibrary(uid);
      return Result.success(library);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
