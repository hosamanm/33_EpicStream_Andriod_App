import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/system_health_card.dart';
import '../widgets/recent_activity_table.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchDashboardData(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(DashboardProvider provider) {
    if (provider.status == DashboardStatus.loading) {
      return const _DashboardSkeleton();
    }

    if (provider.status == DashboardStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchDashboardData(),
      );
    }

    if (provider.status == DashboardStatus.loaded && provider.stats != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Primary Metrics
            _buildPrimaryMetrics(provider),
            const SizedBox(height: 32),

            // 2. Secondary Metrics (Content & Engagement)
            _buildSecondaryMetrics(provider),
            const SizedBox(height: 32),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. Main Analytics & Activity
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartContainer(
                        title: 'User Acquisition Trend (Last 7 Months)',
                        child: UserGrowthChart(data: provider.userGrowthData),
                      ),
                      const SizedBox(height: 32),
                      const Text('Recent Content Updates', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 16),
                      RecentActivityTable(movies: provider.recentMovies),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // 4. Infrastructure & Real-time users
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildSectionHeader('Cloud Infrastructure'),
                      const SystemHealthCard(serviceName: 'Firebase Auth', isOnline: true, latency: '32ms'),
                      const SizedBox(height: 12),
                      const SystemHealthCard(serviceName: 'Firestore Cluster', isOnline: true, latency: '88ms'),
                      const SizedBox(height: 12),
                      const SystemHealthCard(serviceName: 'Cloudflare Stream', isOnline: true, latency: '145ms'),
                      const SizedBox(height: 32),
                      _buildRecentUsersSection(provider),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPrimaryMetrics(DashboardProvider provider) {
    final stats = provider.stats!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.0,
          children: [
            DashboardCard(
              title: 'Total Audience',
              value: _formatNumber(stats.totalUsers),
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              trend: '+5.2%',
            ),
            DashboardCard(
              title: 'Daily Active Users',
              value: _formatNumber(stats.activeUsersToday),
              icon: Icons.bolt_rounded,
              color: Colors.green,
              trend: '+12%',
            ),
            DashboardCard(
              title: 'Total Watch Time',
              value: '${stats.totalWatchHours.toInt()}h',
              icon: Icons.play_circle_fill_rounded,
              color: AdminColors.primary,
              trend: '+8.4%',
            ),
            DashboardCard(
              title: 'Bandwidth (Monthly)',
              value: '${stats.bandwidthUsedTB.toStringAsFixed(1)} TB',
              icon: Icons.speed_rounded,
              color: Colors.orange,
              trend: 'Cloudflare',
              isPositiveTrend: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecondaryMetrics(DashboardProvider provider) {
    final stats = provider.stats!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 2.2,
          children: [
            _MiniStatsCard(title: 'Movies', value: stats.totalMovies.toString(), subtitle: '${stats.publishedMovies} Published', icon: Icons.movie),
            _MiniStatsCard(title: 'Categories', value: stats.totalCategories.toString(), subtitle: '${stats.totalGenres} Genres', icon: Icons.category),
            _MiniStatsCard(title: 'Languages', value: stats.totalLanguages.toString(), subtitle: '${stats.totalCountries} Countries', icon: Icons.language),
            _MiniStatsCard(title: 'Storage', value: '${stats.storageUsedGB.toInt()} GB', subtitle: 'Firebase Storage', icon: Icons.storage),
          ],
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildChartContainer({required String title, required Widget child}) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 32),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRecentUsersSection(DashboardProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Latest Signups', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (provider.recentUsers.isEmpty)
            const Center(child: Text('No recent activity', style: TextStyle(color: Colors.white24, fontSize: 12)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.recentUsers.length,
              separatorBuilder: (_, __) => const Divider(height: 24, color: Colors.white10),
              itemBuilder: (context, index) {
                final user = provider.recentUsers[index];
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18, 
                      backgroundImage: user.profileImage != null ? NetworkImage(user.profileImage!) : null, 
                      child: user.profileImage == null ? const Icon(Icons.person, size: 18) : null
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MiniStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _MiniStatsCard({required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(subtitle, style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 2.0,
              children: List.generate(4, (_) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)))),
            ),
            const SizedBox(height: 32),
            Container(height: 400, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
          ],
        ),
      ),
    );
  }
}
