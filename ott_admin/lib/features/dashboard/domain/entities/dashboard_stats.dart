import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalUsers;
  final int activeUsersToday;
  final int activeUsersWeekly;
  final int activeUsersMonthly;
  
  final int totalMovies;
  final int publishedMovies;
  final int draftMovies;
  final int trendingMovies;
  final int featuredMovies;
  
  final int totalCategories;
  final int totalGenres;
  final int totalLanguages;
  final int totalCountries;
  
  final double totalWatchHours;
  final double todayWatchHours;
  final int totalNotifications;
  
  final double storageUsedGB;
  final double bandwidthUsedTB;

  const DashboardStats({
    required this.totalUsers,
    required this.activeUsersToday,
    required this.activeUsersWeekly,
    required this.activeUsersMonthly,
    required this.totalMovies,
    required this.publishedMovies,
    required this.draftMovies,
    required this.trendingMovies,
    required this.featuredMovies,
    required this.totalCategories,
    required this.totalGenres,
    required this.totalLanguages,
    required this.totalCountries,
    required this.totalWatchHours,
    required this.todayWatchHours,
    required this.totalNotifications,
    required this.storageUsedGB,
    required this.bandwidthUsedTB,
  });

  factory DashboardStats.empty() => const DashboardStats(
        totalUsers: 0,
        activeUsersToday: 0,
        activeUsersWeekly: 0,
        activeUsersMonthly: 0,
        totalMovies: 0,
        publishedMovies: 0,
        draftMovies: 0,
        trendingMovies: 0,
        featuredMovies: 0,
        totalCategories: 0,
        totalGenres: 0,
        totalLanguages: 0,
        totalCountries: 0,
        totalWatchHours: 0.0,
        todayWatchHours: 0.0,
        totalNotifications: 0,
        storageUsedGB: 0.0,
        bandwidthUsedTB: 0.0,
      );

  @override
  List<Object?> get props => [
        totalUsers,
        activeUsersToday,
        totalMovies,
        totalWatchHours,
        storageUsedGB,
      ];
}
