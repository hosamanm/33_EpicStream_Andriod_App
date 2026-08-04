import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_notifier.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Periodically check if email is verified
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      context.read<AuthNotifier>().checkAuthStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_rounded, size: 80, color: AppColors.primaryRed),
              const SizedBox(height: AppDimensions.l),
              Text(
                'Verify Your Email',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.m),
              const Text(
                'We have sent a verification link to your email. Please check your inbox and follow the instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: AppDimensions.xl),
              const CircularProgressIndicator.adaptive(),
              const SizedBox(height: AppDimensions.l),
              TextButton(
                onPressed: () => context.read<AuthNotifier>().logout(),
                child: const Text('CANCEL & LOGOUT', style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
