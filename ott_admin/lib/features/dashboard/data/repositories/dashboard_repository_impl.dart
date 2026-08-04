import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../movies/domain/entities/admin_movie_entity.dart';
import '../../../users/domain/entities/admin_user_entity.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../services/dashboard_service.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardService _service;

  DashboardRepositoryImpl(this._service);

  @override
  Future<Result<DashboardStats>> getPlatformStats() async {
    try {
      final data = await _service.fetchPlatformStats();
      return Result.success(DashboardStats(
        totalUsers: data['totalUsers'],
        activeUsersToday: data['activeUsersToday'],
        activeUsersWeekly: data['activeUsersWeekly'],
        activeUsersMonthly: data['activeUsersMonthly'],
        totalMovies: data['totalMovies'],
        publishedMovies: data['publishedMovies'],
        draftMovies: data['draftMovies'],
        trendingMovies: data['trendingMovies'],
        featuredMovies: data['featuredMovies'],
        totalCategories: data['totalCategories'],
        totalGenres: data['totalGenres'],
        totalLanguages: data['totalLanguages'],
        totalCountries: data['totalCountries'],
        totalWatchHours: data['totalWatchHours'],
        todayWatchHours: data['todayWatchHours'],
        totalNotifications: data['totalNotifications'],
        storageUsedGB: data['storageUsedGB'],
        bandwidthUsedTB: data['bandwidthUsedTB'],
      ));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<int>>> getMonthlyUserGrowth() async {
    // In production, this would fetch from a 'monthly_growth' collection
    return const Result.success([500, 1200, 800, 2500, 1900, 3000, 4200]);
  }

  @override
  Future<Result<List<AdminUserEntity>>> getRecentUsers({int limit = 5}) async {
    try {
      final users = await _service.getRecentUsers(limit: limit);
      return Result.success(users);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<AdminMovieEntity>>> getRecentMovies({int limit = 5}) async {
    try {
      final movies = await _service.getRecentMovies(limit: limit);
      return Result.success(movies);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
