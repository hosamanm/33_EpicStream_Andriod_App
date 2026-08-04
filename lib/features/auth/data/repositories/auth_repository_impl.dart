import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmail(email, password);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Authentication failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmail(email, password, name);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Sign up failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Google sign in failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInAnonymously() async {
    try {
      final userModel = await _remoteDataSource.signInAnonymously();
      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Anonymous sign in failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyPhoneNumber({
    required String phoneNumber,
    int? resendToken,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(String errorMessage) verificationFailed,
  }) async {
    try {
      await _remoteDataSource.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        resendToken: resendToken,
        codeSent: codeSent,
        verificationFailed: verificationFailed,
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
    try {
      final userModel = await _remoteDataSource.signInWithPhoneNumber(verificationId, smsCode);
      return Result.success(userModel);
    } on FirebaseAuthException catch (e) {
      return Result.failure(ServerFailure(e.message ?? 'Phone sign in failed'));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> reloadUser() async {
    try {
      final user = await _remoteDataSource.reloadUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;
}
