import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/social_login_button.dart';
import '../providers/auth_notifier.dart';
import '../providers/register_notifier.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final registerNotifier = context.read<RegisterNotifier>();
      if (!registerNotifier.acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please accept the Terms & Conditions')),
        );
        return;
      }

      context.read<AuthNotifier>().signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            fullName: _nameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final registerNotifier = context.watch<RegisterNotifier>();
    final authNotifier = context.read<AuthNotifier>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name
          AppTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline,
            validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: AppDimensions.m),

          // Email
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                return 'Invalid email format';
              }
              return null;
            },
          ),
          const SizedBox(height: AppDimensions.m),

          // Phone
          AppTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: '+1 123 456 7890',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: AppDimensions.m),

          // Password
          AppTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            prefixIcon: Icons.lock_outline,
            obscureText: registerNotifier.obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(registerNotifier.obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.white70),
              onPressed: () => registerNotifier.togglePasswordVisibility(),
            ),
            onChanged: (val) => registerNotifier.checkPasswordStrength(val),
            validator: (val) => val == null || val.length < 6 ? 'Min 6 characters required' : null,
          ),
          
          // Strength Indicator
          const SizedBox(height: AppDimensions.s),
          _PasswordStrengthBar(strength: registerNotifier.passwordStrength),
          const SizedBox(height: AppDimensions.m),

          // Confirm Password
          AppTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter password',
            prefixIcon: Icons.lock_reset,
            obscureText: registerNotifier.obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(registerNotifier.obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 20, color: Colors.white70),
              onPressed: () => registerNotifier.toggleConfirmPasswordVisibility(),
            ),
            validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: AppDimensions.m),

          // Terms Checkbox
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: registerNotifier.acceptTerms,
                  onChanged: registerNotifier.setAcceptTerms,
                  activeColor: AppColors.primaryRed,
                  side: const BorderSide(color: Colors.white70),
                ),
              ),
              const SizedBox(width: AppDimensions.s),
              Expanded(
                child: Text(
                  'I accept the Terms & Conditions and Privacy Policy',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.l),

          // Sign Up Button
          ElevatedButton(
            onPressed: _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
            ),
            child: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          const SizedBox(height: AppDimensions.l),

          // Social Link
          SocialLoginButton(
            onPressed: () => authNotifier.signInWithGoogle(),
            icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.white),
            label: 'Sign up with Google',
          ),
        ],
      ),
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    Color color;
    String label;
    double progress;

    switch (strength) {
      case PasswordStrength.weak:
        color = Colors.red;
        label = 'Weak';
        progress = 0.33;
        break;
      case PasswordStrength.medium:
        color = Colors.orange;
        label = 'Medium';
        progress = 0.66;
        break;
      case PasswordStrength.strong:
        color = Colors.green;
        label = 'Strong';
        progress = 1.0;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white10,
          color: color,
          minHeight: 4,
        ),
        const SizedBox(height: 4),
        Text(
          'Strength: $label',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
