import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Implementation of [AuthRepository] using Firebase Authentication.
/// Orchestrates data flow between [AuthService] and the Domain Layer.
class FirebaseAuthRepository implements AuthRepository {
  final AuthService _authService;

  FirebaseAuthRepository(this._authService);

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _handleAuth(
      () => _authService.signInWithEmail(email, password),
    );
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    return _handleAuth(() async {
      final credential = await _authService.signUpWithEmail(email, password);
      if (name != null) {
        await credential.user?.updateDisplayName(name);
      }
      return credential;
    });
  }

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    return _handleAuth(() => _authService.signInWithGoogle());
  }

  @override
  Future<Result<UserEntity>> signInAnonymously() async {
    return _handleAuth(() => _authService.signInAnonymously());
  }

  @override
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String errorMessage) verificationFailed,
  }) async {
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        resendToken: resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Note: Automatic verification handling would happen in a Bloc/Notifier
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(e.message ?? 'Verification Failed');
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithPhoneNumber({
    required String verificationId,
    required String smsCode,
  }) async {
    return _handleAuth(() {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return _authService.signInWithPhoneCredential(credential);
    });
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = _authService.currentUser;
      return Result.success(user != null ? _mapFirebaseUser(user) : null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> reloadUser() async {
    try {
      await _authService.reloadUser();
      final user = _authService.currentUser;
      if (user == null) return Result.failure(const ServerFailure('User session lost after reload'));
      return Result.success(_mapFirebaseUser(user));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => 
      _authService.authStateChanges.map((user) => user != null ? _mapFirebaseUser(user) : null);

  // --- Helper Methods ---

  Future<Result<UserEntity>> _handleAuth(Future<UserCredential> Function() authMethod) async {
    try {
      final credential = await authMethod();
      if (credential.user == null) {
        return Result.failure(const ServerFailure('User not found after authentication'));
      }
      return Result.success(_mapFirebaseUser(credential.user!));
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(_mapFirebaseErrorCode(e.code, e.message)));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  UserEntity _mapFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }

  String _mapFirebaseErrorCode(String code, String? message) {
    switch (code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Email is already registered.';
      case 'invalid-email': return 'The email address is invalid.';
      case 'weak-password': return 'The password is too weak.';
      case 'network-request-failed': return 'Network error. Please try again.';
      default: return message ?? 'An unknown authentication error occurred.';
    }
  }
}
