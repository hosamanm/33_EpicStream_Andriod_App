import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
    String? name,
  }) {
    return _repository.signUpWithEmail(
      email: email, 
      password: password, 
      name: name,
    );
  }
}
