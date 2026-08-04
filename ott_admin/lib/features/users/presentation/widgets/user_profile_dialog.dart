import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../providers/admin_user_provider.dart';
import '../../../../core/theme/admin_colors.dart';

class UserProfileDialog extends StatefulWidget {
  final AdminUserEntity user;

  const UserProfileDialog({super.key, required this.user});

  @override
  State<UserProfileDialog> createState() => _UserProfileDialogState();
}

class _UserProfileDialogState extends State<UserProfileDialog> {
  Map<String, dynamic>? _libraryData;
  bool _isLoadingLibrary = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final data = await context.read<AdminUserProvider>().getUserLibrary(widget.user.uid);
    if (mounted) {
      setState(() {
        _libraryData = data;
        _isLoadingLibrary = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AdminColors.backgroundDark,
      child: Container(
        width: 900,
        height: 750,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('User Insight & Control', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 48, color: Colors.white10),
            
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side: Profile & Actions
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileHeader(theme, user),
                          const SizedBox(height: 32),
                          _buildStatsGrid(user),
                          const SizedBox(height: 40),
                          const Text('MODERATION ACTIONS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          _ActionButton(
                            label: user.isBlocked ? 'ACTIVATE USER' : 'BLOCK USER',
                            icon: user.isBlocked ? Icons.check_circle_outline : Icons.block_flipped,
                            color: user.isBlocked ? Colors.greenAccent : Colors.orangeAccent,
                            onPressed: () => context.read<AdminUserProvider>().blockUser(user.uid, !user.isBlocked),
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'SEND PASSWORD RESET',
                            icon: Icons.mail_outline,
                            color: Colors.blueAccent,
                            onPressed: () {
                              // Trigger reset
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset email queued.')));
                            },
                          ),
                          const SizedBox(height: 12),
                          _ActionButton(
                            label: 'DELETE PERMANENTLY',
                            icon: Icons.delete_forever,
                            color: Colors.redAccent,
                            onPressed: () async {
                              final confirmed = await _showDeleteConfirm(context);
                              if (confirmed && context.mounted) {
                                await context.read<AdminUserProvider>().deleteUser(user.uid);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const VerticalDivider(width: 64, color: Colors.white10),

                  // Right Side: Content Engagement
                  Expanded(
                    flex: 3,
                    child: _isLoadingLibrary 
                      ? const Center(child: CircularProgressIndicator())
                      : DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              const TabBar(
                                indicatorColor: AdminColors.primary,
                                tabs: [
                                  Tab(text: 'History'),
                                  Tab(text: 'Favorites'),
                                  Tab(text: 'Watchlist'),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _LibraryListView(items: _libraryData?['history'] ?? [], icon: Icons.history),
                                    _LibraryListView(items: _libraryData?['favorites'] ?? [], icon: Icons.favorite_border),
                                    _LibraryListView(items: _libraryData?['watchlist'] ?? [], icon: Icons.bookmark_border),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, AdminUserEntity user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: AdminColors.primary.withOpacity(0.1),
          backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null,
          child: user.profileImage == null ? const Icon(Icons.person, size: 36, color: AdminColors.primary) : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Badge(label: user.isBlocked ? 'BLOCKED' : 'ACTIVE', color: user.isBlocked ? Colors.redAccent : Colors.greenAccent),
                  const SizedBox(width: 8),
                  if (user.isGuest) const _Badge(label: 'GUEST', color: Colors.blueAccent),
                  if (user.isEmailVerified) const Icon(Icons.verified, color: Colors.blue, size: 14),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminUserEntity user) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _StatItem(label: 'Watch Time', value: '${user.watchTimeMinutes} min', icon: Icons.timer_outlined),
        _StatItem(label: 'Downloads', value: user.downloadCount.toString(), icon: Icons.download_done_rounded),
        _StatItem(label: 'Devices', value: user.deviceCount.toString(), icon: Icons.devices),
        _StatItem(label: 'Last Login', value: user.lastLogin.toString().split(' ')[0], icon: Icons.login),
      ],
    );
  }

  Future<bool> _showDeleteConfirm(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Permanent Deletion'),
        content: const Text('This action cannot be undone. All user data, history, and library items will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE USER', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }
}

class _LibraryListView extends StatelessWidget {
  final List<dynamic> items;
  final IconData icon;
  const _LibraryListView({required this.items, required this.icon});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white10),
            const SizedBox(height: 16),
            const Text('No items found', style: TextStyle(color: Colors.white24)),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          leading: Container(
            width: 40,
            height: 56,
            decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
            child: item['posterUrl'] != null ? Image.network(item['posterUrl'], fit: BoxFit.cover) : const Icon(Icons.movie_outlined, size: 20),
          ),
          title: Text(item['title'] ?? 'Unknown Movie', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text(item['addedAt'] != null ? 'Added: ${item['addedAt']}' : '', style: const TextStyle(fontSize: 11, color: Colors.white38)),
          trailing: item['progress'] != null ? Text('${(item['progress'] * 100).toInt()}%', style: const TextStyle(color: AdminColors.primary, fontSize: 12)) : null,
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color.withOpacity(0.5))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white38),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withOpacity(0.4)),
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
