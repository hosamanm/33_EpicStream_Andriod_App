import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';
import '../models/activity_log_model.dart';
import '../services/activity_log_service.dart';

class ActivityLogRepositoryImpl implements ActivityLogRepository {
  final ActivityLogService _service;

  ActivityLogRepositoryImpl(this._service);

  @override
  Future<Result<List<ActivityLogEntity>>> getLogs({
    int limit = 50,
    ActivityModule? module,
    ActivityAction? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final logs = await _service.fetchLogs(
        limit: limit,
        module: module?.name,
        action: action?.name,
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(logs);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logAction(ActivityLogEntity log) async {
    try {
      final model = ActivityLogModel(
        id: log.id,
        adminId: log.adminId,
        adminEmail: log.adminEmail,
        action: log.action,
        module: log.module,
        targetId: log.targetId,
        description: log.description,
        metadata: log.metadata,
        ipAddress: log.ipAddress,
        timestamp: log.timestamp,
      );
      await _service.recordLog(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> exportLogs(String format) async {
    // Logic for CSV/PDF generation would go here
    return const Result.success(null);
  }
}
