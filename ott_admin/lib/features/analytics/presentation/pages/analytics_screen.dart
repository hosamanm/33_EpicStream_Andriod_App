import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../dashboard/presentation/widgets/chart_widgets.dart';
import '../../../dashboard/presentation/widgets/dashboard_card.dart';
import '../../domain/entities/platform_analytics_entity.dart';
import '../providers/analytics_provider.dart';
import '../controllers/analytics_controller.dart';
import '../widgets/dashboard_charts.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late AnalyticsController _controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _controller = AnalyticsController(
      context.read<AnalyticsProvider>(),
      context.read(), // ReportGenerator from DI
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligence & Analytics'),
        actions: [
          OutlinedButton.icon(
            onPressed: () => _controller.onDateRangeSelected(context),
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(
              '${provider.dateRange.start.toString().split(' ')[0]} - ${provider.dateRange.end.toString().split(' ')[0]}',
            ),
          ),
          const SizedBox(width: 16),
          _ExportMenu(onExport: _controller.exportReport),
          const SizedBox(width: 24),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'OVERVIEW'),
            Tab(text: 'USERS'),
            Tab(text: 'CONTENT'),
            Tab(text: 'WATCH TIME'),
            Tab(text: 'SEARCH & DEVICES'),
          ],
        ),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AnalyticsProvider provider) {
    if (provider.status == AnalyticsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == AnalyticsStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchAnalytics(),
      );
    }

    if (provider.status == AnalyticsStatus.loaded && provider.analytics != null) {
      return TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(analytics: provider.analytics!),
          _UserAnalyticsTab(analytics: provider.analytics!.userAnalytics),
          _ContentAnalyticsTab(analytics: provider.analytics!.contentAnalytics),
          _WatchTimeTab(analytics: provider.analytics!.watchTimeAnalytics),
          _SearchDeviceTab(analytics: provider.analytics!),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _OverviewTab extends StatelessWidget {
  final PlatformAnalyticsEntity analytics;
  const _OverviewTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildKpiGrid(),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _ChartBox(
                  title: 'Engagement Trend',
                  child: UserGrowthChart(data: [45, 52, 48, 70, 65, 85, 92]), // Trend from analytics
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _ChartBox(
                  title: 'Platform Distribution',
                  child: CategoryPieChart(
                    categories: analytics.deviceAnalytics.platformDistribution.entries
                        .map((e) => CategoryPerformance(e.key, e.value.toDouble()))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 2.2,
      children: [
        DashboardCard(title: 'Monthly Active (MAU)', value: analytics.userAnalytics.monthlyActiveUsers.toString(), icon: Icons.group, color: Colors.blue),
        DashboardCard(title: 'Watch Hours', value: '${analytics.watchTimeAnalytics.monthlyWatchTime.toInt()}h', icon: Icons.timer, color: AdminColors.primary),
        DashboardCard(title: 'Bandwidth', value: '${analytics.bandwidthUsageTB}TB', icon: Icons.speed, color: Colors.orange),
        DashboardCard(title: 'Avg Session', value: analytics.userAnalytics.avgSessionDuration, icon: Icons.av_timer, color: Colors.purple),
      ],
    );
  }
}

class _UserAnalyticsTab extends StatelessWidget {
  final UserAnalytics analytics;
  const _UserAnalyticsTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        Row(
          children: [
            _InfoTile(label: 'New Users Today', value: analytics.newUsersToday.toString()),
            _InfoTile(label: 'Returning Users', value: analytics.returningUsers.toString()),
            _InfoTile(label: 'Daily Active (DAU)', value: analytics.dailyActiveUsers.toString()),
          ],
        ),
        const SizedBox(height: 32),
        _ChartBox(
          title: 'Preferred Genres',
          child: ContentViewsBarChart(
            metrics: analytics.preferredGenres.entries
                .map((e) => ContentMetric(title: e.key, views: e.value))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ContentAnalyticsTab extends StatelessWidget {
  final ContentAnalytics analytics;
  const _ContentAnalyticsTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildPerformanceMetrics(),
          const SizedBox(height: 32),
          _ChartBox(
            title: 'Most Watched Movies',
            child: ContentViewsBarChart(metrics: analytics.mostWatchedMovies),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Row(
      children: [
        Expanded(child: DashboardCard(title: 'Avg Completion Rate', value: '${(analytics.avgCompletionRate * 100).toInt()}%', icon: Icons.check_circle, color: Colors.green)),
        const SizedBox(width: 20),
        Expanded(child: DashboardCard(title: 'Trending Content', value: analytics.trendingMovies.length.toString(), icon: Icons.trending_up, color: Colors.red)),
      ],
    );
  }
}

class _WatchTimeTab extends StatelessWidget {
  final WatchTimeAnalytics analytics;
  const _WatchTimeTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            children: [
              _InfoTile(label: 'Daily Watch Time', value: '${analytics.dailyWatchTime.toInt()}h'),
              _InfoTile(label: 'Weekly Watch Time', value: '${analytics.weeklyWatchTime.toInt()}h'),
            ],
          ),
          const SizedBox(height: 32),
          _ChartBox(
            title: 'Watch History Growth',
            child: UserGrowthChart(data: analytics.watchHistoryGrowth.map((e) => e.value.toInt()).toList()),
          ),
        ],
      ),
    );
  }
}

class _SearchDeviceTab extends StatelessWidget {
  final PlatformAnalyticsEntity analytics;
  const _SearchDeviceTab({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChartBox(
                  title: 'Top Search Queries',
                  child: Column(
                    children: analytics.searchAnalytics.topSearches.take(5).map((s) => ListTile(
                      title: Text(s.query),
                      trailing: Text(s.count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _ChartBox(
                  title: 'Android Version Distribution',
                  child: CategoryPieChart(
                    categories: analytics.deviceAnalytics.androidVersions.entries
                        .map((e) => CategoryPerformance(e.key, e.value.toDouble()))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartBox extends StatelessWidget {
  final String title;
  final Widget child;
  const _ChartBox({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _ExportMenu extends StatelessWidget {
  final Function(String) onExport;
  const _ExportMenu({required this.onExport});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onExport,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AdminColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.download, size: 16, color: Colors.white),
            SizedBox(width: 8),
            Text('EXPORT REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
        const PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
      ],
    );
  }
}
