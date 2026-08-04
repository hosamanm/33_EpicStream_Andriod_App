import '../../../../core/utils/result.dart';
import '../entities/admin_notification_entity.dart';

abstract class AdminNotificationRepository {
  Future<Result<List<AdminNotificationEntity>>> getNotificationHistory({int limit = 20});
  Future<Result<void>> sendNotification(AdminNotificationEntity notification);
  Future<Result<void>> deleteNotification(String id);
  Stream<List<AdminNotificationEntity>> watchNotifications();
}
