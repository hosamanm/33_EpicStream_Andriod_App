import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/providers/onboarding_notifier.dart';
import '../../features/auth/presentation/providers/splash_notifier.dart';

/// Middleware for GoRouter to protect routes and handle app flow.
class RouteGuard {
  final AuthNotifier _authNotifier;
  final OnboardingNotifier _onboardingNotifier;
  final SplashNotifier _splashNotifier;

  RouteGuard({
    required AuthNotifier authNotifier,
    required OnboardingNotifier onboardingNotifier,
    required SplashNotifier splashNotifier,
  })  : _authNotifier = authNotifier,
        _onboardingNotifier = onboardingNotifier,
        _splashNotifier = splashNotifier;

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final authState = _authNotifier.state;
    final hasSeenOnboarding = _onboardingNotifier.hasSeenOnboarding;
    final isInitialized = _splashNotifier.step == SplashStep.completed;
    
    // Path helpers
    final String location = state.uri.path;
    final bool isOnboarding = location == '/onboarding';
    final bool isSplash = location == '/splash';
    final bool isWelcome = location == '/welcome';
    final bool isLogin = location == '/login';
    final bool isRegister = location == '/register';

    // 1. Splash Phase: Stay on splash until background checks (Auth/Network) are 100% done
    if (!isInitialized || authState is AuthLoading) {
      return isSplash ? null : '/splash';
    }

    // 2. Onboarding Phase: If first launch, force them to onboarding
    if (!hasSeenOnboarding) {
      return isOnboarding ? null : '/onboarding';
    }

    // 3. Unauthenticated Phase: user finished onboarding but isn't logged in
    if (authState is Unauthenticated || authState is AuthInitial || authState is AuthError) {
      // If they are on Onboarding/Splash but already finished those steps, send to Welcome
      if (isOnboarding || isSplash) {
        return '/welcome';
      }

      // Allow access to auth screens
      final bool isAuthPath = isLogin || isRegister || isWelcome || 
          location.contains('forgot-password') || 
          location.contains('phone-login') ||
          location.contains('otp-verification');

      return isAuthPath ? null : '/welcome';
    }

    // 4. Authenticated Phase: User is logged in
    if (authState is Authenticated || authState is AuthRegistered) {
      final user = authState is Authenticated ? authState.userProfile : (authState as AuthRegistered).userProfile;

      // Verification & Profile Completion checks
      if (!user.isGuest && !user.isEmailVerified && location != '/verify-email') {
        return '/verify-email';
      }
      if (authState is AuthRegistered && user.favoriteGenres.isEmpty && location != '/complete-profile') {
        return '/complete-profile';
      }

      // Redirect authenticated users away from Splash/Welcome/Auth/Onboarding to Home
      if (isSplash || isWelcome || isLogin || isRegister || isOnboarding) {
        return '/';
      }
    }

    return null; // Allow navigation to requested route
  }
}
