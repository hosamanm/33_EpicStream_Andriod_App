import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/admin_user_provider.dart';
import '../controllers/admin_user_controller.dart';
import '../widgets/user_table.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late AdminUserController _controller;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AdminUserController(context.read<AdminUserProvider>());
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<AdminUserProvider>().fetchUsers();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUserProvider>().fetchUsers(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          _ActionButton(
            label: 'REFRESH',
            icon: Icons.refresh,
            onPressed: () => provider.fetchUsers(isRefresh: true),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'EXPORT CSV',
            icon: Icons.download_rounded,
            onPressed: () => _controller.exportUsersToCsv(),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search users by name or email...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AdminColors.surfaceDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _FilterToggle(
                  label: 'Blocked Only',
                  value: provider.filterBlockedOnly,
                  onChanged: provider.toggleBlockedFilter,
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AdminUserProvider provider) {
    if (provider.status == UserManagementStatus.loading && provider.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == UserManagementStatus.error && provider.users.isEmpty) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchUsers(isRefresh: true),
      );
    }

    final filteredUsers = provider.filteredUsers;
    if (filteredUsers.isEmpty && provider.status != UserManagementStatus.loading) {
      return const Center(child: Text('No users found matching your criteria.'));
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: UserTable(
              users: filteredUsers,
              controller: _controller,
            ),
          ),
          const SizedBox(height: 24),
          if (provider.status == UserManagementStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            )
          else if (!provider.hasMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('End of user list', style: TextStyle(color: Colors.white24)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: TextButton(
                onPressed: () => provider.fetchUsers(),
                child: const Text('LOAD MORE USERS'),
              ),
            ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: AdminColors.primary.withOpacity(0.2),
      checkmarkColor: AdminColors.primary,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
      ),
    );
  }
}
