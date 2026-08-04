import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../providers/register_notifier.dart';
import '../widgets/register_form.dart';

/// Professional Registration Screen for OTT Stream.
/// Features Glassmorphism and modern UI components.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterNotifier(),
      child: Scaffold(
        body: Stack(
          children: [
            // 1. Cinematic Background
            Positioned.fill(
              child: Image.network(
                'https://images.unsplash.com/photo-1574267432553-4b4628081c31?q=80&w=2073&auto=format&fit=crop',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.darkBackground,
                ),
              ),
            ),
            // Dark Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppDimensions.l),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      children: [
                        const Icon(Icons.play_circle_fill, size: 60, color: AppColors.primaryRed),
                        const SizedBox(height: AppDimensions.m),
                        Text(
                          'CREATE ACCOUNT',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.l),

                        // 3. Glassmorphism Card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(AppDimensions.xl),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: const RegisterForm(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.l),
                        
                        // Back to Login
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: RichText(
                            text: TextSpan(
                              text: 'Already have an account? ',
                              style: const TextStyle(color: Colors.white70),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: AppColors.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 4. Loading Overlay
            Consumer<AuthNotifier>(
              builder: (context, auth, _) {
                if (auth.state is AuthLoading) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
