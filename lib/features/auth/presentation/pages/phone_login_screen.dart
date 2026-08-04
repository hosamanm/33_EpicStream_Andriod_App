import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/phone_auth_notifier.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<PhoneAuthNotifier>().sendOtp(_completePhoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneState = context.watch<PhoneAuthNotifier>().state;

    // Listen for OTP Sent state to navigate
    if (phoneState == PhoneAuthState.otpSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.push('/otp-verification');
      });
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: AppColors.darkBackground)),
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.phone_android_rounded, size: 64, color: AppColors.primaryRed),
                            const SizedBox(height: AppDimensions.l),
                            Text(
                              'Phone Login',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: AppDimensions.s),
                            Text(
                              'Enter your phone number to receive a one-time password (OTP).',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: AppDimensions.xl),
                            
                            IntlPhoneField(
                              controller: _phoneController,
                              initialCountryCode: 'US',
                              style: const TextStyle(color: Colors.white),
                              dropdownTextStyle: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                labelStyle: const TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (phone) => _completePhoneNumber = phone.completeNumber,
                            ),

                            const SizedBox(height: AppDimensions.xl),
                            
                            ElevatedButton(
                              onPressed: phoneState == PhoneAuthState.sendingOtp ? null : _handleSendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                              ),
                              child: phoneState == PhoneAuthState.sendingOtp
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('SEND OTP', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),

                            if (context.watch<PhoneAuthNotifier>().errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(top: AppDimensions.m),
                                child: Text(
                                  context.watch<PhoneAuthNotifier>().errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
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
}
