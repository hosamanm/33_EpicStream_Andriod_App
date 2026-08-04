import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

/// A reusable menu tile for the profile screen.
class ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Widget? trailing;

  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(AppDimensions.s),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.1) ?? (isDark ? Colors.white10 : Colors.black12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        child: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black87), size: 20),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
    );
  }
}
