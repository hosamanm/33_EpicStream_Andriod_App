import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/admin_auth_provider.dart';
import '../../features/auth/presentation/providers/admin_auth_state.dart';
import 'admin_router.dart';

/// Middleware for GoRouter to protect Admin routes.
/// Ensures only authenticated users with correct roles can access specific sections.
class AdminGuard {
  final AdminAuthProvider _authProvider;

  AdminGuard(this._authProvider);

  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    final authState = _authProvider.state;
    final String path = state.matchedLocation;
    final bool isLoggingIn = path == AdminRouter.login;

    // 1. Initial/Loading: Wait for auth check
    if (authState.status == AdminAuthStatus.initial || authState.status == AdminAuthStatus.loading) {
      return null; 
    }

    // 2. Unauthenticated: Send to login
    if (authState.status == AdminAuthStatus.unauthenticated) {
      return isLoggingIn ? null : AdminRouter.login;
    }

    // 3. Unauthorized: Not an admin at all
    if (authState.status == AdminAuthStatus.unauthorized) {
      return AdminRouter.unauthorized;
    }

    // 4. Authenticated: Validate Role-Based Access
    if (authState.status == AdminAuthStatus.authenticated) {
      final admin = authState.admin;
      if (admin == null) return AdminRouter.login;

      if (isLoggingIn) return AdminRouter.dashboard;

      // Deep-link protection (Granular RBAC)
      
      // Users Management: Super Admin & Admin only
      if (path == AdminRouter.users && !admin.canManageUsers) {
        return AdminRouter.unauthorized;
      }

      // Settings: Super Admin only
      if (path == AdminRouter.settings && !admin.isSuperAdmin) {
        return AdminRouter.unauthorized;
      }

      // Content Management: Super Admin, Admin, Editor
      final contentPaths = [
        AdminRouter.movies,
        AdminRouter.trailers,
        AdminRouter.banners,
      ];
      if (contentPaths.contains(path) && !admin.canManageContent) {
        return AdminRouter.unauthorized;
      }

      // Metadata: moderator and above
      final metadataPaths = [
        AdminRouter.categories,
        AdminRouter.genres,
        AdminRouter.languages,
        AdminRouter.countries,
        AdminRouter.ageRatings,
        AdminRouter.homeSections,
      ];
      if (metadataPaths.contains(path) && !admin.canManageMetadata) {
        return AdminRouter.unauthorized;
      }

      // Notifications: moderator and above
      if (path == AdminRouter.notifications && !admin.canSendNotifications) {
        return AdminRouter.unauthorized;
      }

      return null; // Access granted
    }

    return null;
  }
}
