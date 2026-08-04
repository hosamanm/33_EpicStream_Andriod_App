import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/routes/app_router.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_notifier.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground, 
      body: Stack(
        children: [
          // 1. Cinematic Background
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=2050&auto=format&fit=cover',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.darkBackground),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.play_circle_fill, size: 80, color: AppColors.primaryRed),
                  const SizedBox(height: AppDimensions.l),
                  Text(
                    'EPICSTREAM',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.m),
                  const Text(
                    'Unlimited movies, TV shows, and more. Watch anywhere. Cancel anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: AppDimensions.xxl),

                  ElevatedButton(
                    onPressed: () => context.push(AppRouter.login),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.l),
                    ),
                    child: const Text('SIGN IN', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: AppDimensions.m),
                  OutlinedButton(
                    onPressed: () => context.push(AppRouter.register),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white70),
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.l),
                    ),
                    child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: AppDimensions.m),
                  TextButton(
                    onPressed: () => authNotifier.signInAnonymously(),
                    child: const Text(
                      'CONTINUE AS GUEST',
                      style: TextStyle(color: Colors.white60, letterSpacing: 1.1, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xl),

                  // 3. Footer Links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _footerLink('Privacy Policy'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('|', style: TextStyle(color: Colors.white24)),
                      ),
                      _footerLink('Terms of Service'),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.m),
                  Text(
                    _version,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white12, fontSize: 10),
                  ),
                  const SizedBox(height: AppDimensions.l),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String title) {
    return GestureDetector(
      onTap: () {}, 
      child: Text(
        title,
        style: const TextStyle(color: Colors.white38, fontSize: 12, decoration: TextDecoration.underline),
      ),
    );
  }
}
