import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:epic_stream/core/di/injection.dart';
import 'package:epic_stream/core/services/navigation_service.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/onboarding_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/splash_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_state.dart';
import 'package:epic_stream/screens/splash/splash_screen.dart'; 
import 'package:epic_stream/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/welcome_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/login_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/register_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/phone_login_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:epic_stream/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:epic_stream/features/home/presentation/pages/dashboard_screen.dart';
import 'package:epic_stream/features/movies/presentation/pages/movie_details_screen.dart';
import 'package:epic_stream/features/player/presentation/pages/player_screen.dart';
import 'package:epic_stream/features/profile/presentation/pages/settings_screen.dart';
import 'package:epic_stream/features/profile/presentation/pages/feedback_screen.dart';
import 'package:epic_stream/features/profile/presentation/pages/profile_screen.dart';
import 'package:epic_stream/features/watchlist/presentation/pages/watchlist_screen.dart';
import 'package:epic_stream/features/history/presentation/pages/continue_watching_screen.dart';
import 'package:epic_stream/features/history/presentation/pages/watch_history_screen.dart';
import 'package:epic_stream/features/notifications/presentation/pages/notification_screen.dart';
import 'package:epic_stream/features/notifications/presentation/pages/notification_settings_screen.dart';
import 'package:epic_stream/features/search/presentation/pages/search_screen.dart';
import 'package:epic_stream/features/categories/presentation/pages/categories_screen.dart';
import 'package:epic_stream/features/downloads/presentation/pages/downloads_screen.dart';

class AppRouter {
  AppRouter._();

  // Route Paths - Static constants for easy access
  static const String root = '/';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String verifyEmail = '/verify-email';
  static const String completeProfile = '/complete-profile';

  static final GoRouter router = GoRouter(
    navigatorKey: sl<NavigationService>().navigatorKey,
    initialLocation: splash,
    refreshListenable: Listenable.merge([
      sl<AuthNotifier>(),
      sl<OnboardingNotifier>(),
      sl<SplashNotifier>(),
    ]),
    debugLogDiagnostics: true,
    
    redirect: (context, state) {
      final authState = sl<AuthNotifier>().state;
      final splashStep = sl<SplashNotifier>().step;
      final onboardingDone = sl<OnboardingNotifier>().hasSeenOnboarding;

      final String location = state.matchedLocation;
      final bool isSplash = location == splash;
      final bool isOnboarding = location == onboarding;
      
      final bool isAuthScreen = location == welcome || 
                               location == login || 
                               location == register || 
                               location == phoneLogin || 
                               location == forgotPassword ||
                               location == otpVerification ||
                               location == verifyEmail ||
                               location == completeProfile;

      // 1. Splash Phase: Absolute priority until initialization is complete
      if (splashStep != SplashStep.completed) {
        return isSplash ? null : splash;
      }

      // 2. Onboarding Phase: Show if mandatory
      if (!onboardingDone) {
        return isOnboarding ? null : onboarding;
      }

      // 3. User is Logged In
      if (authState is Authenticated || authState is AuthRegistered) {
        // If on splash, onboarding, or login screens, go to root
        if (isSplash || isOnboarding || isAuthScreen) {
          return root;
        }
        return null;
      }

      // 4. User is Not Logged In
      if (authState is Unauthenticated || authState is AuthInitial || authState is AuthError || authState is AuthLoading) {
        // Wait on current screen if loading, but if on splash/onboarding, must move to welcome
        if (isSplash || isOnboarding) {
          return welcome;
        }
        // If trying to access app content without being logged in, go to welcome
        if (!isAuthScreen) {
          return welcome;
        }
      }

      return null;
    },

    routes: [
      GoRoute(path: splash, builder: (context, state) => const EpicStreamSplashScreen()),
      GoRoute(path: onboarding, builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: phoneLogin, builder: (context, state) => const PhoneLoginScreen()),
      GoRoute(path: otpVerification, builder: (context, state) => const OtpVerificationScreen()),
      GoRoute(path: verifyEmail, builder: (context, state) => const VerifyEmailScreen()),
      GoRoute(path: completeProfile, builder: (context, state) => const CompleteProfileScreen()),
      
      GoRoute(
        path: root,
        builder: (context, state) => const DashboardScreen(),
        routes: [
          GoRoute(
            path: 'movie-details/:id',
            builder: (context, state) => MovieDetailsScreen(movieId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'player/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              final isTrailer = state.uri.queryParameters['isTrailer'] == 'true';
              return PlayerScreen(movieId: id, isTrailer: isTrailer);
            },
          ),
        ],
      ),

      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/downloads', builder: (context, state) => const DownloadsScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/watchlist', builder: (context, state) => const WatchlistScreen()),
      GoRoute(path: '/continue-watching', builder: (context, state) => const ContinueWatchingScreen()),
      GoRoute(path: '/history', builder: (context, state) => const WatchHistoryScreen()),
      GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
      GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );
}
