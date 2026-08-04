import '../../../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';

abstract class UserProfileRepository {
  Future<Result<UserProfileEntity?>> getUserProfile(String uid);
  Future<Result<void>> createUserProfile(UserProfileEntity profile);
  Future<Result<void>> updateUserProfile(UserProfileEntity profile);
  Future<Result<void>> deleteUserProfile(String uid);
  Stream<UserProfileEntity?> watchUserProfile(String uid);
}
