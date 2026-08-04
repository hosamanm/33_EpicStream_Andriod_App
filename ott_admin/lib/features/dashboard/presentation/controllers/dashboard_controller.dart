import '../providers/dashboard_provider.dart';

/// Controller for the Admin Dashboard.
/// Orchestrates data refreshing and potentially handles user interactions with charts/stats.
class DashboardController {
  final DashboardProvider _provider;

  DashboardController(this._provider);

  /// Initializes the dashboard by fetching platform metrics and analytics.
  Future<void> init() async {
    await _provider.fetchDashboardData();
  }

  /// Manually refreshes the dashboard data.
  Future<void> refresh() async {
    await _provider.fetchDashboardData();
  }

  /// Handles clicking on a specific KPI card (e.g., to navigate to a detailed view).
  void onKpiCardPressed(String metricType) {
    // Logic to navigate or filter data based on the KPI clicked.
  }
}
