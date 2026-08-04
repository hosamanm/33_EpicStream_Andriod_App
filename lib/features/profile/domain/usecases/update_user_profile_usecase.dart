import '../../../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class UpdateUserProfileUseCase {
  final UserProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<Result<void>> call(UserProfileEntity profile) {
    return _repository.updateUserProfile(profile);
  }
}
