import 'dart:async';
import 'package:flutter/material.dart';
import 'package:epic_stream/core/services/device_service.dart';
import 'package:epic_stream/core/services/secure_storage_service.dart';
import 'package:epic_stream/features/profile/domain/entities/user_profile_entity.dart';
import 'package:epic_stream/features/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:epic_stream/features/profile/domain/usecases/create_user_profile_usecase.dart';
import 'package:epic_stream/features/profile/domain/usecases/update_user_profile_usecase.dart';
import 'package:epic_stream/features/auth/domain/repositories/auth_repository.dart';
import 'package:epic_stream/features/auth/domain/usecases/login_usecase.dart';
import 'package:epic_stream/features/auth/domain/usecases/signup_usecase.dart';
import 'package:epic_stream/features/auth/domain/usecases/logout_usecase.dart';
import 'package:epic_stream/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:epic_stream/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final SignUpUseCase _signUpUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final CreateUserProfileUseCase _createUserProfileUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage;
  final DeviceService _deviceService;

  StreamSubscription? _authSubscription;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required SignUpUseCase signUpUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required CreateUserProfileUseCase createUserProfileUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required AuthRepository authRepository,
    required SecureStorageService secureStorage,
    required DeviceService deviceService,
  })  : _loginUseCase = loginUseCase,
        _signUpUseCase = signUpUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _getUserProfileUseCase = getUserProfileUseCase,
        _createUserProfileUseCase = createUserProfileUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _authRepository = authRepository,
        _secureStorage = secureStorage,
        _deviceService = deviceService {
    _init();
  }

  AuthState _state = const AuthInitial();
  AuthState get state => _state;

  void _init() {
    _authSubscription = _authRepository.authStateChanges.listen((user) async {
      if (user == null) {
        _updateState(const Unauthenticated());
      } else {
        await _fetchAndSetUserProfile(
          user.id, 
          email: user.email, 
          name: user.displayName, 
          photoUrl: user.photoUrl,
          isVerified: user.isEmailVerified,
          isGuest: user.email.isEmpty,
        );
      }
    }, onError: (e) {
      debugPrint('AuthNotifier Init Error: $e');
      _updateState(const Unauthenticated());
    });
  }

  void _updateState(AuthState newState) {
    if (_state == newState) return;
    _state = newState;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      _updateState(const AuthLoading());
      final result = await _getCurrentUserUseCase();
      
      if (result.isSuccess && result.data != null) {
        final user = result.data!;
        await _fetchAndSetUserProfile(
          user.id, 
          email: user.email,
          name: user.displayName,
          photoUrl: user.photoUrl,
          isVerified: user.isEmailVerified,
          isGuest: user.email.isEmpty,
        );
      } else {
        _updateState(const Unauthenticated());
      }
    } catch (e) {
      debugPrint('checkAuthStatus Error: $e');
      _updateState(const Unauthenticated());
    }
  }

  Future<void> _fetchAndSetUserProfile(
    String uid, {
    String? email, 
    String? name, 
    String? photoUrl, 
    bool isVerified = false,
    bool isGuest = false,
  }) async {
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();
      final result = await _getUserProfileUseCase(uid);
      
      if (result.isSuccess && result.data != null) {
        var profile = result.data!;
        profile = profile.copyWith(
          isEmailVerified: isVerified,
          lastLogin: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _updateUserProfileUseCase(profile);
        _updateState(Authenticated(profile));
      } else {
        final now = DateTime.now();
        final newProfile = UserProfileEntity(
          uid: uid,
          displayName: name ?? (isGuest ? 'Guest User' : 'OTT User'),
          email: email ?? '',
          photoUrl: photoUrl,
          favoriteGenres: const [],
          language: 'en',
          themeMode: 'dark',
          isGuest: isGuest,
          isEmailVerified: isVerified,
          deviceInfo: deviceInfo,
          createdAt: now,
          lastLogin: now,
          updatedAt: now,
        );
        await _createUserProfileUseCase(newProfile);
        _updateState(Authenticated(newProfile));
      }
    } catch (e) {
      debugPrint('_fetchAndSetUserProfile Error: $e');
      // Fallback state if profile fetching fails but auth is active
      _updateState(const Unauthenticated());
    }
  }

  Future<void> login(String email, String password, {bool rememberMe = false}) async {
    _updateState(const AuthLoading());
    try {
      if (rememberMe) {
        await _secureStorage.saveRememberedEmail(email); 
      } else {
        await _secureStorage.deleteRememberedEmail();
      }

      final result = await _loginUseCase(email: email, password: password);
      if (result.isError) {
        _updateState(AuthError(result.failure.message));
      }
    } catch (e) {
      _updateState(AuthError(e.toString()));
    }
  }

  Future<String?> getSavedEmail() async {
    return _secureStorage.getRememberedEmail();
  }

  Future<void> signInWithGoogle() async {
    _updateState(const AuthLoading());
    final result = await _authRepository.signInWithGoogle();
    if (result.isError) {
      _updateState(AuthError(result.failure.message));
    }
  }

  Future<void> signInAnonymously() async {
    _updateState(const AuthLoading());
    final result = await _authRepository.signInAnonymously();
    if (result.isError) {
      _updateState(AuthError(result.failure.message));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _updateState(const AuthLoading());
    final result = await _signUpUseCase(email: email, password: password, name: fullName);
    
    if (result.isSuccess) {
      final user = result.data;
      final now = DateTime.now();
      final deviceInfo = await _deviceService.getDeviceInfo();
      
      final profile = UserProfileEntity(
        uid: user.id,
        displayName: fullName,
        email: email,
        favoriteGenres: const [],
        language: 'en',
        themeMode: 'dark',
        isGuest: false,
        isEmailVerified: user.isEmailVerified,
        deviceInfo: deviceInfo,
        createdAt: now,
        lastLogin: now,
        updatedAt: now,
      );
      await _createUserProfileUseCase(profile);
      await _authRepository.sendEmailVerification();
      _updateState(AuthRegistered(profile));
    } else {
      _updateState(AuthError(result.failure.message));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _updateState(const AuthLoading());
    final result = await _forgotPasswordUseCase(email);
    if (result.isError) {
      _updateState(AuthError(result.failure.message));
    } else {
      _updateState(const Unauthenticated());
    }
  }

  Future<void> logout() async {
    _updateState(const AuthLoading());
    final result = await _logoutUseCase();
    if (result.isError) {
      _updateState(AuthError(result.failure.message));
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
