import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/profile_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensuring localization is not null using '!'
    final l10n = AppLocalizations.of(context)!;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
        children: [
          _buildSectionHeader(context, l10n.appearance),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.themeMode),
            subtitle: Text(profile?.themeMode.toUpperCase() ?? 'SYSTEM'),
            onTap: () => _showThemeDialog(context, profileProvider, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.appLanguage),
            subtitle: Text(_getLanguageName(profile?.language)),
            onTap: () => _showLanguageDialog(context, profileProvider, l10n),
          ),

          const Divider(height: 32, color: Colors.white10),
          _buildSectionHeader(context, l10n.playbackExperience),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.subtitles_outlined),
            title: Text(l10n.subtitles),
            subtitle: Text(l10n.showSubtitlesDefault),
            value: profile?.subtitleEnabled ?? true,
            activeTrackColor: AppColors.primaryRed,
            onChanged: (val) {
              if (profile != null) {
                profileProvider.updateProfile(profile.copyWith(subtitleEnabled: val));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack_outlined),
            title: Text(l10n.audioLanguage),
            subtitle: Text(profile?.audioLanguage.toUpperCase() ?? 'ENGLISH'),
            onTap: () => _showAudioLanguageDialog(context, profileProvider, l10n),
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(l10n.pushNotifications),
            value: profile?.notificationEnabled ?? true,
            activeTrackColor: AppColors.primaryRed,
            onChanged: (val) {
              if (profile != null) {
                profileProvider.updateProfile(profile.copyWith(notificationEnabled: val));
              }
            },
          ),

          const Divider(height: 32, color: Colors.white10),
          _buildSectionHeader(context, l10n.storageCache),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: Text(l10n.clearCache),
            subtitle: Text(l10n.removeTempFiles),
            onTap: () => _clearCache(context, l10n),
          ),
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: Text(l10n.downloadQuality),
            subtitle: const Text('Standard (Recommended)'),
          ),

          const Divider(height: 32, color: Colors.white10),
          _buildSectionHeader(context, l10n.aboutEpicStream),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.privacyPolicy),
            onTap: () => context.push('/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsConditions),
            onTap: () => context.push('/terms'),
          ),
          ListTile(
            leading: const Icon(Icons.help_center_outlined),
            title: Text(l10n.helpCenter),
            onTap: () => context.push('/faq'),
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(l10n.licenses),
            onTap: () => showLicensePage(context: context),
          ),
          const SizedBox(height: AppDimensions.xxl),
        ],
      ),
    );
  }

  String _getLanguageName(String? code) {
    switch (code) {
      case 'kn': return 'ಕನ್ನಡ (Kannada)';
      case 'hi': return 'हिन्दी (Hindi)';
      case 'te': return 'తెలుగు (Telugu)';
      case 'ta': return 'தமிழ் (Tamil)';
      default: return 'English';
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ProfileProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectTheme),
        children: ['light', 'dark', 'system'].map((mode) {
          return SimpleDialogOption(
            onPressed: () {
              if (provider.profile != null) {
                provider.updateProfile(provider.profile!.copyWith(themeMode: mode));
              }
              Navigator.pop(context);
            },
            child: Text(mode.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, ProfileProvider provider, AppLocalizations l10n) {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'kn', 'name': 'ಕನ್ನಡ (Kannada)'},
      {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
      {'code': 'te', 'name': 'తెలుగు (Telugu)'},
      {'code': 'ta', 'name': 'தமிழ் (Tamil)'},
    ];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectLanguage),
        children: languages.map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              if (provider.profile != null) {
                provider.updateProfile(provider.profile!.copyWith(language: lang['code']!));
              }
              Navigator.pop(context);
            },
            child: Text(lang['name']!),
          );
        }).toList(),
      ),
    );
  }

  void _showAudioLanguageDialog(BuildContext context, ProfileProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.defaultAudio),
        children: ['en', 'kn', 'hi', 'te', 'ta'].map((lang) {
          return SimpleDialogOption(
            onPressed: () {
              if (provider.profile != null) {
                provider.updateProfile(provider.profile!.copyWith(audioLanguage: lang));
              }
              Navigator.pop(context);
            },
            child: Text(lang.toUpperCase()),
          );
        }).toList(),
      ),
    );
  }

  void _clearCache(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCacheTitle),
        content: Text(l10n.clearCacheMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.cacheCleared)),
              );
            },
            child: Text(l10n.clear, style: const TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }
}
