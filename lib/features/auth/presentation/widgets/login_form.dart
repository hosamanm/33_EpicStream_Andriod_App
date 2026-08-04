import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/app_text_field.dart';
import 'package:epic_stream/core/widgets/social_login_button.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_notifier.dart';
import 'package:epic_stream/core/routes/app_router.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await context.read<AuthNotifier>().getSavedEmail();
    if (savedEmail != null && mounted) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthNotifier>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            rememberMe: _rememberMe,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authNotifier = context.read<AuthNotifier>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.l),
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                size: 20,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.s),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                    activeColor: AppColors.primaryRed,
                  ),
                  Text('Remember Me', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                ],
              ),
              TextButton(
                onPressed: () => context.push(AppRouter.forgotPassword),
                child: Text(
                  'Forgot Password?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.l),
          ElevatedButton(
            onPressed: _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
            ),
            child: const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            children: [
              const Expanded(child: Divider(color: Colors.white24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
                child: Text('OR CONTINUE WITH', style: theme.textTheme.labelSmall?.copyWith(color: Colors.white38)),
              ),
              const Expanded(child: Divider(color: Colors.white24)),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            children: [
              Expanded(
                child: SocialLoginButton(
                  onPressed: () => authNotifier.signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
                  label: 'Google',
                ),
              ),
              const SizedBox(width: AppDimensions.m),
              Expanded(
                child: SocialLoginButton(
                  onPressed: () => context.push(AppRouter.phoneLogin),
                  icon: const Icon(Icons.phone_android, size: 20, color: Colors.white),
                  label: 'Phone',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.m),
          OutlinedButton.icon(
            onPressed: () => authNotifier.signInAnonymously(),
            icon: const Icon(Icons.person_outline, size: 20),
            label: const Text('CONTINUE AS GUEST'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
            ),
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
              GestureDetector(
                onTap: () => context.push(AppRouter.register),
                child: Text('Register Now', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
