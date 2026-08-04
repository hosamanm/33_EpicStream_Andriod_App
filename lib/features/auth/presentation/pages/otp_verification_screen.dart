import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/phone_auth_notifier.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phoneNotifier = context.watch<PhoneAuthNotifier>();
    final phoneState = phoneNotifier.state;

    // Listen for success state to navigate to home
    if (phoneState == PhoneAuthState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/');
      });
    }

    const focusedBorderColor = AppColors.primaryRed;
    const fillColor = Colors.transparent;
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.white24),
      ),
    );

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.security_rounded, size: 64, color: AppColors.primaryRed),
                          const SizedBox(height: AppDimensions.l),
                          Text(
                            'Verify OTP',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: AppDimensions.s),
                          Text(
                            'Enter the 6-digit code sent to your phone.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: AppDimensions.xl),
                          
                          Pinput(
                            length: 6,
                            controller: _pinController,
                            focusNode: _focusNode,
                            defaultPinTheme: defaultPinTheme,
                            focusedPinTheme: defaultPinTheme.copyDecorationWith(
                              border: Border.all(color: focusedBorderColor),
                            ),
                            onCompleted: (pin) {
                              phoneNotifier.verifyOtp(pin);
                            },
                          ),

                          const SizedBox(height: AppDimensions.xl),
                          
                          if (phoneState == PhoneAuthState.verifying)
                            const Center(child: CircularProgressIndicator.adaptive())
                          else
                            ElevatedButton(
                              onPressed: () => phoneNotifier.verifyOtp(_pinController.text),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                              ),
                              child: const Text('VERIFY & PROCEED', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),

                          const SizedBox(height: AppDimensions.l),

                          // Resend Timer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive code? ",
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                              ),
                              TextButton(
                                onPressed: phoneNotifier.timerCount == 0 ? () {
                                  // Logic to resend OTP
                                } : null,
                                child: Text(
                                  phoneNotifier.timerCount == 0 
                                    ? 'Resend OTP' 
                                    : 'Resend in ${phoneNotifier.timerCount}s',
                                  style: TextStyle(
                                    color: phoneNotifier.timerCount == 0 ? AppColors.primaryRed : Colors.white38,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (phoneNotifier.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: AppDimensions.m),
                              child: Text(
                                phoneNotifier.errorMessage!,
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
        ],
      ),
    );
  }
}
