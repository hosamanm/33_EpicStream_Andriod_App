import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authNotifier = context.read<AuthNotifier>();
      await authNotifier.sendPasswordReset(_emailController.text.trim());
      
      if (mounted && authNotifier.state is! AuthError) {
        setState(() => _isEmailSent = true); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthNotifier>().state;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: AppColors.darkBackground),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.l),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: _isEmailSent ? _buildSuccessView(theme) : _buildFormView(theme, authState),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView(ThemeData theme, AuthState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.primaryRed),
          const SizedBox(height: AppDimensions.l),
          Text(
            'Forgot Password?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppDimensions.s),
          Text(
            'Enter your registered email to receive a password reset link.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppDimensions.xl),
          AppTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: AppDimensions.xl),
          if (state is AuthLoading)
            const Center(child: CircularProgressIndicator.adaptive())
          else
            ElevatedButton(
              onPressed: _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              ),
              child: const Text('SEND RESET LINK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          if (state is AuthError)
            Padding(
              padding: const EdgeInsets.only(top: AppDimensions.m),
              child: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeData theme) {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_rounded, size: 64, color: Colors.greenAccent),
        const SizedBox(height: AppDimensions.l),
        Text(
          'Email Sent!',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: AppDimensions.s),
        Text(
          'We have sent a password reset link to ${_emailController.text}. Please check your inbox.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: AppDimensions.xl),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('BACK TO LOGIN', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
