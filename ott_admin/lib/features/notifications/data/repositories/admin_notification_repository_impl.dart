import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../../domain/repositories/admin_notification_repository.dart';
import '../models/admin_notification_model.dart';
import '../services/admin_notification_service.dart';

class AdminNotificationRepositoryImpl implements AdminNotificationRepository {
  final AdminNotificationService _service;

  AdminNotificationRepositoryImpl(this._service);

  @override
  Future<Result<List<AdminNotificationEntity>>> getNotificationHistory({int limit = 20}) async {
    try {
      final models = await _service.fetchNotificationHistory(limit: limit);
      return Result.success(models);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendNotification(AdminNotificationEntity notification) async {
    try {
      final model = AdminNotificationModel(
        id: '',
        title: notification.title,
        body: notification.body,
        imageUrl: notification.imageUrl,
        type: notification.type,
        target: notification.target,
        targetValues: notification.targetValues,
        scheduleType: notification.scheduleType,
        scheduledFor: notification.scheduledFor,
        deepLinkType: notification.deepLinkType,
        deepLinkValue: notification.deepLinkValue,
        createdAt: DateTime.now(),
      );
      await _service.sendNotification(model);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteNotification(String id) async {
    try {
      await _service.deleteNotification(id);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<AdminNotificationEntity>> watchNotifications() {
    return _service.watchNotifications();
  }
}
