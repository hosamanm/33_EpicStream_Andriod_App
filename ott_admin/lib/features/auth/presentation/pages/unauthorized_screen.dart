import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';
import '../providers/admin_auth_provider.dart';

/// Screen shown when an authenticated user does not have administrative privileges.
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AdminColors.backgroundDark,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(48),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: AdminColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gpp_bad_outlined, size: 80, color: AdminColors.primary),
              const SizedBox(height: 24),
              Text(
                'Access Denied',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your account does not have administrative privileges to access this dashboard. Please contact the system administrator if you believe this is an error.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.read<AdminAuthProvider>().logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('LOGOUT & SWITCH ACCOUNT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
