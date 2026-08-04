import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/core/widgets/loading_widget.dart';
import 'package:epic_stream/features/profile/presentation/providers/profile_provider.dart';
import 'package:epic_stream/features/profile/data/services/profile_service.dart';
import 'package:epic_stream/features/profile/presentation/widgets/profile_header.dart';
import 'package:epic_stream/features/profile/presentation/widgets/profile_menu_tile.dart';
import 'package:epic_stream/features/profile/presentation/controllers/profile_controller.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileController _controller;

  @override
  void initState() {
    super.initState();
    // Explicitly type the service lookup
    _controller = ProfileController(
      context.read<ProfileService>(), 
      context.read<ProfileProvider>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();
    
    if (provider.isLoading) {
      return const Scaffold(body: Center(child: AppLoadingWidget(message: 'Loading Profile...')));
    }

    final profile = provider.profile;
    if (profile == null) {
      return const Scaffold(
        body: AppErrorView(
          title: 'Profile Not Found',
          message: 'We could not retrieve your profile information.',
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(
              profile: profile,
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: _buildStatsGrid(context),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.fromLTRB(AppDimensions.m, AppDimensions.l, AppDimensions.m, AppDimensions.s),
                child: Text('Content Library', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              ProfileMenuTile(
                icon: Icons.bookmark_outline_rounded,
                title: 'My Watchlist',
                onTap: () => context.push('/watchlist'),
              ),
              ProfileMenuTile(
                icon: Icons.history_rounded,
                title: 'Watch History',
                onTap: () => context.push('/history'),
              ),
              ProfileMenuTile(
                icon: Icons.favorite_border_rounded,
                title: 'Favorites',
                onTap: () => context.push('/favorites'),
              ),
              ProfileMenuTile(
                icon: Icons.download_done_rounded,
                title: 'My Downloads',
                onTap: () {},
              ),
              
              const Padding(
                padding: EdgeInsets.fromLTRB(AppDimensions.m, AppDimensions.l, AppDimensions.m, AppDimensions.s),
                child: Text('Account Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              ProfileMenuTile(
                icon: Icons.settings_outlined,
                title: 'App Settings',
                onTap: () => context.push('/settings'),
              ),
              
              const Padding(
                padding: EdgeInsets.fromLTRB(AppDimensions.m, AppDimensions.l, AppDimensions.m, AppDimensions.s),
                child: Text('Support', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              ),
              ProfileMenuTile(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                onTap: () => context.push('/feedback'),
              ),
              ProfileMenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Help Center & FAQ',
                onTap: () => context.push('/faq'),
              ),
              ProfileMenuTile(
                icon: Icons.info_outline_rounded,
                title: 'Privacy Policy',
                onTap: () => context.push('/privacy'),
              ),
              ProfileMenuTile(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                onTap: () => context.push('/terms'),
              ),
              
              const SizedBox(height: AppDimensions.xl),
              ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Logout',
                color: AppColors.primaryRed,
                onTap: () async {
                  await _controller.logout();
                },
              ),
              ProfileMenuTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                color: Colors.white38,
                onTap: () => _controller.deleteAccount(context),
              ),
              const SizedBox(height: AppDimensions.xxl),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        _StatItem(label: 'Watchlist', count: 0, onTap: () => context.push('/watchlist')),
        _StatItem(label: 'History', count: 0, onTap: () => context.push('/history')),
        const _StatItem(label: 'Downloads', count: 0),
        _StatItem(label: 'Favorites', count: 0, onTap: () => context.push('/favorites')),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback? onTap;
  const _StatItem({required this.label, required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
