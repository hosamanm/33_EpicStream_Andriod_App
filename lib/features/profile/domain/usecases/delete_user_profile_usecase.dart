import '../../../../core/utils/result.dart';
import '../repositories/user_profile_repository.dart';

class DeleteUserProfileUseCase {
  final UserProfileRepository _repository;

  DeleteUserProfileUseCase(this._repository);

  Future<Result<void>> call(String uid) {
    return _repository.deleteUserProfile(uid);
  }
}
