import 'package:flutter/material.dart';
import '../../data/services/profile_service.dart';
import '../providers/profile_provider.dart';

/// Controller for the Profile module.
/// Decouples the UI from the underlying service and provider logic.
class ProfileController {
  final ProfileService _profileService;
  final ProfileProvider _provider;

  ProfileController(this._profileService, this._provider);

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? country,
    List<String>? favoriteGenres,
    String? profileImage,
  }) async {
    if (_provider.profile == null) return;

    final updatedProfile = _provider.profile!.copyWith(
      displayName: fullName,
      phoneNumber: phone,
      country: country,
      favoriteGenres: favoriteGenres,
      photoUrl: profileImage,
      updatedAt: DateTime.now(),
    );

    await _profileService.updateProfile(updatedProfile);
  }

  Future<void> logout() async {
    await _profileService.logout();
  }

  Future<void> deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is permanent. All your library data, history, and favorites will be lost. You may need to sign in again to confirm this action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE ACCOUNT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _profileService.deleteAccount();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().contains('recent-login') ? 'Please logout and login again to delete your account.' : e.toString()}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }
}
