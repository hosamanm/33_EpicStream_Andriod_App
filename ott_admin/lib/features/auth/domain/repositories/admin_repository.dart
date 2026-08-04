import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/result.dart';
import '../entities/admin_entity.dart';

abstract class AdminRepository {
  Future<Result<UserCredential>> signIn(String email, String password);
  Future<Result<void>> signOut();
  Future<Result<AdminEntity?>> getAdminData(String uid);
  Future<Result<void>> resetPassword(String email);
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
