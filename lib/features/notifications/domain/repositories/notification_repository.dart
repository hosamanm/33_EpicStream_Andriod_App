import '../../../../core/utils/result.dart';
import '../entities/notification_history_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationHistoryEntity>> watchNotificationHistory();
  Future<Result<void>> markAsRead(String historyId);
  Future<Result<void>> markAllAsRead();
  Future<Result<void>> deleteNotification(String historyId);
  Future<Result<int>> getUnreadCount();
  
  // FCM Token management
  Future<Result<void>> updateFcmToken(String token);
  
  // Notification Settings
  Future<Result<void>> updateNotificationSettings({
    required bool enabled,
    bool? marketingEnabled,
    List<String>? genrePreferences,
  });
}
