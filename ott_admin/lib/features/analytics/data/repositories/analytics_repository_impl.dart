import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/platform_analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../services/analytics_service.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsService _service;

  AnalyticsRepositoryImpl(this._service);

  @override
  Future<Result<PlatformAnalyticsEntity>> getPlatformAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    String? platform,
  }) async {
    try {
      final data = await _service.fetchAggregateStats(
        startDate: startDate,
        endDate: endDate,
        country: country,
        platform: platform,
      );

      return Result.success(PlatformAnalyticsEntity(
        userAnalytics: UserAnalytics(
          totalUsers: data['totalUsers'] ?? 0,
          newUsersToday: data['newUsersToday'] ?? 0,
          returningUsers: data['returningUsers'] ?? 0,
          dailyActiveUsers: data['dailyActiveUsers'] ?? 0,
          weeklyActiveUsers: data['weeklyActiveUsers'] ?? 0,
          monthlyActiveUsers: data['monthlyActiveUsers'] ?? 0,
          avgSessionDuration: data['avgSessionDuration'] ?? '0m',
          preferredLanguages: const {'English': 75000, 'Spanish': 12000, 'Hindi': 45000},
          preferredGenres: const {'Action': 85000, 'Drama': 62000, 'Comedy': 54000},
          preferredDevices: const {'Phone': 120000, 'Tablet': 35000, 'Web': 15000},
          mostActiveUsers: const [],
        ),
        contentAnalytics: ContentAnalytics(
          mostWatchedMovies: (data['mostWatchedMovies'] as List? ?? []).map((m) => ContentMetric(
            title: m['title'] ?? '',
            views: m['views'] ?? 0,
            avgWatchTime: 45.0,
            completionRate: (m['completion'] as num? ?? 0).toDouble(),
          )).toList(),
          leastWatchedMovies: (data['leastWatchedMovies'] as List? ?? []).map((m) => ContentMetric(
            title: m['title'] ?? '',
            views: m['views'] ?? 0,
            avgWatchTime: 5.0,
            completionRate: (m['completion'] as num? ?? 0).toDouble(),
          )).toList(),
          trendingMovies: const [],
          avgCompletionRate: 0.72,
          topGenres: const {'Action': 4500, 'Drama': 3200},
          topLanguages: const {'English': 5000, 'Hindi': 3000},
          topCategories: const {'Movies': 120000, 'TV Shows': 85000, 'Documentaries': 15000},
        ),
        watchTimeAnalytics: WatchTimeAnalytics(
          dailyWatchTime: (data['todayWatchHours'] as num? ?? 0).toDouble(),
          weeklyWatchTime: (data['watchHours'] as num? ?? 0).toDouble(),
          monthlyWatchTime: ((data['watchHours'] as num? ?? 0) * 4).toDouble(),
          avgMovieCompletion: 0.68,
          continueWatchingUsage: 1250,
          watchHistoryGrowth: [
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 6)), 1200),
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 5)), 1500),
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 4)), 1100),
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 3)), 1800),
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 2)), 2100),
            TimeSeriesData(DateTime.now().subtract(const Duration(days: 1)), 1900),
            TimeSeriesData(DateTime.now(), 2400),
          ],
        ),
        searchAnalytics: SearchAnalytics(
          topSearches: (data['searchStats']?['topSearches'] as List? ?? []).map((s) => SearchQueryMetric(
            query: s['query'] ?? '',
            count: s['count'] ?? 0,
          )).toList(),
          failedSearches: (data['searchStats']?['failedSearches'] as List? ?? []).map((s) => SearchQueryMetric(
            query: s['query'] ?? '',
            count: s['count'] ?? 0,
          )).toList(),
          popularGenres: const {'Action': 150, 'Sci-Fi': 120},
          popularActors: const {'Tom Cruise': 80, 'Scarlett Johansson': 75},
        ),
        deviceAnalytics: DeviceAnalytics(
          deviceModels: Map<String, int>.from(data['deviceStats']?['deviceModels'] ?? {}),
          androidVersions: Map<String, int>.from(data['deviceStats']?['androidVersions'] ?? {}),
          platformDistribution: Map<String, int>.from(data['deviceStats']?['platformDistribution'] ?? {}),
          appVersions: const {'1.0.0': 150000, '1.1.0': 20000},
        ),
        bandwidthUsageTB: (data['bandwidthUsageTB'] as num? ?? 0).toDouble(),
        storageUsageTB: (data['storageUsageTB'] as num? ?? 0).toDouble(),
      ));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> getUserActivityData() async {
    return const Result.success([50000, 65000, 75000, 85000, 95000, 110000, 125000]);
  }
}
