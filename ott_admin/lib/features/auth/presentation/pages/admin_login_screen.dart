import 'package:flutter/material.dart';
import '../widgets/admin_login_form.dart';
import '../../../../core/theme/admin_colors.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.backgroundDark,
      body: Row(
        children: [
          // Left Side: Branding/Visual
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=2059&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.play_circle_fill, size: 80, color: AdminColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      'OTT STREAM',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unified Platform Management Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w300,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Right Side: Login Form
          Expanded(
            flex: 4,
            child: Container(
              color: AdminColors.surfaceDark,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 64),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: const AdminLoginForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
