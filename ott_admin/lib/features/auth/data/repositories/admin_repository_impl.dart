import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../services/admin_service.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminService _adminService;
  final ActivityLogRepository _logRepository;

  AdminRepositoryImpl(this._adminService, this._logRepository);

  @override
  Future<Result<UserCredential>> signIn(String email, String password) async {
    try {
      final credential = await _adminService.login(email, password);
      
      // Log successful login
      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: credential.user?.uid ?? 'unknown',
        adminEmail: email,
        action: ActivityAction.login,
        module: ActivityModule.auth,
        targetId: credential.user?.uid ?? '',
        description: 'Admin logged in successfully',
        ipAddress: '0.0.0.0', // To be captured by Cloud Function or Client
        timestamp: DateTime.now(),
      ));

      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      final email = _adminService.currentUser?.email ?? 'unknown';
      final uid = _adminService.currentUser?.uid ?? 'unknown';
      
      await _adminService.logout();

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: uid,
        adminEmail: email,
        action: ActivityAction.logout,
        module: ActivityModule.auth,
        targetId: uid,
        description: 'Admin logged out',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<AdminEntity?>> getAdminData(String uid) async {
    try {
      final admin = await _adminService.getAdminData(uid);
      return Result.success(admin);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    try {
      await _adminService.sendPasswordResetEmail(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges => _adminService.authStateChanges;

  @override
  User? get currentUser => _adminService.currentUser;
}
