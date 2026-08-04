import 'package:equatable/equatable.dart';

class PlatformAnalyticsEntity extends Equatable {
  // User Analytics
  final UserAnalytics userAnalytics;
  // Content Analytics
  final ContentAnalytics contentAnalytics;
  // Watch Time Analytics
  final WatchTimeAnalytics watchTimeAnalytics;
  // Search Analytics
  final SearchAnalytics searchAnalytics;
  // Device Analytics
  final DeviceAnalytics deviceAnalytics;
  // Infrastructure
  final double bandwidthUsageTB;
  final double storageUsageTB;

  const PlatformAnalyticsEntity({
    required this.userAnalytics,
    required this.contentAnalytics,
    required this.watchTimeAnalytics,
    required this.searchAnalytics,
    required this.deviceAnalytics,
    required this.bandwidthUsageTB,
    required this.storageUsageTB,
  });

  @override
  List<Object?> get props => [userAnalytics, contentAnalytics, watchTimeAnalytics, searchAnalytics, deviceAnalytics];
}

class UserAnalytics extends Equatable {
  final int totalUsers;
  final int newUsersToday;
  final int returningUsers;
  final int dailyActiveUsers;
  final int weeklyActiveUsers;
  final int monthlyActiveUsers;
  final String avgSessionDuration;
  final Map<String, int> preferredLanguages;
  final Map<String, int> preferredGenres;
  final Map<String, int> preferredDevices;
  final List<ActiveUserMetric> mostActiveUsers;

  const UserAnalytics({
    required this.totalUsers,
    required this.newUsersToday,
    required this.returningUsers,
    required this.dailyActiveUsers,
    required this.weeklyActiveUsers,
    required this.monthlyActiveUsers,
    required this.avgSessionDuration,
    required this.preferredLanguages,
    required this.preferredGenres,
    required this.preferredDevices,
    required this.mostActiveUsers,
  });

  @override
  List<Object?> get props => [totalUsers, dailyActiveUsers, weeklyActiveUsers, monthlyActiveUsers];
}

class ContentAnalytics extends Equatable {
  final List<ContentMetric> mostWatchedMovies;
  final List<ContentMetric> leastWatchedMovies;
  final List<ContentMetric> trendingMovies;
  final double avgCompletionRate;
  final Map<String, int> topGenres;
  final Map<String, int> topLanguages;
  final Map<String, int> topCategories;

  const ContentAnalytics({
    required this.mostWatchedMovies,
    required this.leastWatchedMovies,
    required this.trendingMovies,
    required this.avgCompletionRate,
    required this.topGenres,
    required this.topLanguages,
    required this.topCategories,
  });

  @override
  List<Object?> get props => [mostWatchedMovies, trendingMovies, avgCompletionRate];
}

class WatchTimeAnalytics extends Equatable {
  final double dailyWatchTime;
  final double weeklyWatchTime;
  final double monthlyWatchTime;
  final double avgMovieCompletion;
  final int continueWatchingUsage;
  final List<TimeSeriesData> watchHistoryGrowth;

  const WatchTimeAnalytics({
    required this.dailyWatchTime,
    required this.weeklyWatchTime,
    required this.monthlyWatchTime,
    required this.avgMovieCompletion,
    required this.continueWatchingUsage,
    required this.watchHistoryGrowth,
  });

  @override
  List<Object?> get props => [dailyWatchTime, weeklyWatchTime, monthlyWatchTime];
}

class SearchAnalytics extends Equatable {
  final List<SearchQueryMetric> topSearches;
  final List<SearchQueryMetric> failedSearches;
  final Map<String, int> popularGenres;
  final Map<String, int> popularActors;

  const SearchAnalytics({
    required this.topSearches,
    required this.failedSearches,
    required this.popularGenres,
    required this.popularActors,
  });

  @override
  List<Object?> get props => [topSearches, failedSearches];
}

class DeviceAnalytics extends Equatable {
  final Map<String, int> androidVersions;
  final Map<String, int> deviceModels;
  final Map<String, int> platformDistribution; // Phone, Tablet, Web
  final Map<String, int> appVersions;

  const DeviceAnalytics({
    required this.androidVersions,
    required this.deviceModels,
    required this.platformDistribution,
    required this.appVersions,
  });

  @override
  List<Object?> get props => [androidVersions, deviceModels, platformDistribution];
}

class CategoryPerformance {
  final String label;
  final double viewPercentage;
  const CategoryPerformance(this.label, this.viewPercentage);
}

class ContentMetric {
  final String title;
  final int views;
  final double avgWatchTime;
  final double completionRate;

  const ContentMetric({required this.title, required this.views, this.avgWatchTime = 0, this.completionRate = 0});
}

class ActiveUserMetric {
  final String name;
  final int sessions;
  final double watchTime;

  const ActiveUserMetric({required this.name, required this.sessions, required this.watchTime});
}

class SearchQueryMetric {
  final String query;
  final int count;

  const SearchQueryMetric({required this.query, required this.count});
}

class TimeSeriesData {
  final DateTime date;
  final double value;

  const TimeSeriesData(this.date, this.value);
}
