import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    if (profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.m),
        children: [
          _buildHeader('General'),
          SwitchListTile.adaptive(
            title: const Text('Allow Notifications'),
            subtitle: const Text('Receive alerts for all app activities'),
            value: profile.notificationEnabled,
            activeColor: AppColors.primaryRed,
            onChanged: (val) => profileProvider.updateProfile(profile.copyWith(notificationEnabled: val)),
          ),
          
          const Divider(height: 32),
          _buildHeader('Marketing & Updates'),
          SwitchListTile.adaptive(
            title: const Text('New Movie Releases'),
            subtitle: const Text('Get notified when new content is added'),
            value: true, // Internal state or from specialized settings document
            onChanged: (val) {},
          ),
          SwitchListTile.adaptive(
            title: const Text('Personalized Recommendations'),
            subtitle: const Text('Based on your watch history'),
            value: true,
            onChanged: (val) {},
          ),
          
          const Divider(height: 32),
          _buildHeader('Genre Alerts'),
          Wrap(
            spacing: 8,
            children: profile.favoriteGenres.map((genre) {
              return FilterChip(
                label: Text(genre),
                selected: true,
                onSelected: (val) {},
                selectedColor: AppColors.primaryRed.withOpacity(0.2),
                checkmarkColor: AppColors.primaryRed,
              );
            }).toList(),
          ),
          
          const SizedBox(height: AppDimensions.xxl),
          const Center(
            child: Text(
              'System notifications like security alerts and maintenance cannot be disabled.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
