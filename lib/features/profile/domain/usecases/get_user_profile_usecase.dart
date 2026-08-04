import '../../../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class GetUserProfileUseCase {
  final UserProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Result<UserProfileEntity?>> call(String uid) {
    return _repository.getUserProfile(uid);
  }
}
