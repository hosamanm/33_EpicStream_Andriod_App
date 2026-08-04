import '../../../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/user_profile_repository.dart';

class CreateUserProfileUseCase {
  final UserProfileRepository _repository;

  CreateUserProfileUseCase(this._repository);

  Future<Result<void>> call(UserProfileEntity profile) {
    return _repository.createUserProfile(profile);
  }
}
