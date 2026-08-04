import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Abstract repository defining authentication operations.
abstract class AuthRepository {
  // Email Auth
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  // Social & Alternative Auth
  Future<Result<UserEntity>> signInWithGoogle();
  
  Future<Result<UserEntity>> signInAnonymously();

  // Phone Auth
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String errorMessage) verificationFailed,
  });

  Future<Result<UserEntity>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  });

  // Account Management
  Future<Result<void>> signOut();
  
  Future<Result<void>> deleteAccount();
  
  Future<Result<void>> sendPasswordResetEmail(String email);
  
  Future<Result<void>> sendEmailVerification();

  // User State
  Future<Result<UserEntity?>> getCurrentUser();
  
  Future<Result<UserEntity>> reloadUser();
  
  Stream<UserEntity?> get authStateChanges;
}
