import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/result.dart';
import '../entities/admin_user_entity.dart';
import '../entities/admin_user_page.dart';

abstract class AdminUserRepository {
  Future<Result<AdminUserPage>> getUsers({int limit = 20, DocumentSnapshot? lastDoc});
  Future<Result<void>> updateUserStatus(String uid, {required bool isBlocked});
  Future<Result<void>> deleteUser(String uid);
  Future<Result<Map<String, dynamic>>> getUserLibrary(String uid);
}
