import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SocialLoginButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
        backgroundColor: backgroundColor ?? (isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
        foregroundColor: foregroundColor ?? (isDark ? Colors.white : Colors.black87),
        side: BorderSide(
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
}
