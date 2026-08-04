import '../../../../core/utils/result.dart';
import '../../../movies/domain/entities/admin_movie_entity.dart';
import '../../../users/domain/entities/admin_user_entity.dart';
import '../entities/dashboard_stats.dart';

abstract class DashboardRepository {
  Future<Result<DashboardStats>> getPlatformStats();
  Future<Result<List<int>>> getMonthlyUserGrowth();
  Future<Result<List<AdminUserEntity>>> getRecentUsers({int limit = 5});
  Future<Result<List<AdminMovieEntity>>> getRecentMovies({int limit = 5});
}
