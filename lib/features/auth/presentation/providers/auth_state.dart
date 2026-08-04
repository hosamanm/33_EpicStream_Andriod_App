import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/user_profile_entity.dart';

/// Sealed class representing all possible Authentication states.
/// Using a sealed class ensures exhaustive switch/case handling in the UI.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// The state when the app is first launched and hasn't checked for a session yet.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// A generic loading state for authentication-related activities.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// The state when a user is successfully logged in and their profile is fetched.
class Authenticated extends AuthState {
  final UserProfileEntity userProfile;
  const Authenticated(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

/// The state when there is no active session (user logged out or never logged in).
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// The state when an authentication attempt (login/signup) fails.
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// The state immediately after a successful registration.
/// Useful for triggering welcome dialogs or analytics events.
class AuthRegistered extends AuthState {
  final UserProfileEntity userProfile;
  const AuthRegistered(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}
