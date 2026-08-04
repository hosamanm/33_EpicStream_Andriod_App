import '../../../../core/utils/result.dart';
import '../entities/activity_log_entity.dart';

abstract class ActivityLogRepository {
  Future<Result<List<ActivityLogEntity>>> getLogs({
    int limit = 50,
    ActivityModule? module,
    ActivityAction? action,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Result<void>> logAction(ActivityLogEntity log);
  
  Future<Result<void>> exportLogs(String format);
}
