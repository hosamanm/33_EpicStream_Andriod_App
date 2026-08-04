import '../../../../core/utils/result.dart';
import '../entities/platform_analytics_entity.dart';

abstract class AnalyticsRepository {
  Future<Result<PlatformAnalyticsEntity>> getPlatformAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    String? platform,
  });

  Future<Result<List<int>>> getUserActivityData();
}
