import 'package:flutter/material.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../providers/admin_user_provider.dart';
import '../widgets/user_profile_dialog.dart';

/// Controller for User Management UI logic.
/// Decouples the UI actions from the provider state updates.
class AdminUserController {
  final AdminUserProvider _provider;

  AdminUserController(this._provider);

  void onSearchChanged(String query) {
    _provider.setSearchQuery(query);
  }

  void onViewUser(BuildContext context, AdminUserEntity user) {
    showDialog(
      context: context,
      builder: (_) => UserProfileDialog(user: user),
    );
  }

  Future<void> onBlockToggle(AdminUserEntity user) async {
    await _provider.blockUser(user.uid, !user.isBlocked);
  }

  Future<void> onDeleteUser(BuildContext context, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure? This user will be permanently removed from the platform.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _provider.deleteUser(uid);
    }
  }

  void exportUsersToCsv() {
    // Logic for generating and downloading CSV of user data
  }
}
