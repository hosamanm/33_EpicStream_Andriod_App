import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Result<void>> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
