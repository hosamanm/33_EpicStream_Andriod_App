import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Service to handle navigation and global UI interactions.
/// Allows navigation from business logic layers without BuildContext.
class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Navigation shortcut using GoRouter.
  void navigateTo(String path, {Object? extra}) {
    navigatorKey.currentContext?.go(path, extra: extra);
  }

  /// Push a new route onto the stack.
  void pushTo(String path, {Object? extra}) {
    navigatorKey.currentContext?.push(path, extra: extra);
  }

  /// Show a global snackbar.
  void showSnackBar(String message, {bool isError = false}) {
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void goBack() => navigatorKey.currentState?.pop();
}
