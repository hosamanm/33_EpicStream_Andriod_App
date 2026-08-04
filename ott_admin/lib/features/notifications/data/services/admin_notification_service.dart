import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/admin_notification_model.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';

/// Service responsible for managing notification data and triggering delivery.
class AdminNotificationService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final ActivityLogRepository _logRepository;
  final FirebaseAuth _auth;

  AdminNotificationService(
    this._firestore, 
    this._functions, 
    this._logRepository, 
    this._auth
  );

  String get _adminEmail => _auth.currentUser?.email ?? 'system';
  String get _adminId => _auth.currentUser?.uid ?? 'system';

  /// Fetches historical notifications.
  Future<List<AdminNotificationModel>> fetchNotificationHistory({int limit = 20}) async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => AdminNotificationModel.fromFirestore(doc)).toList();
  }

  /// Saves a notification to Firestore and triggers the Cloud Function for delivery.
  Future<void> sendNotification(AdminNotificationModel notification) async {
    // 1. Save to historical log
    final docRef = await _firestore.collection('admin_notifications').add(notification.toFirestore());

    // 2. Trigger Cloud Function for FCM delivery
    try {
      final HttpsCallable callable = _functions.httpsCallable('sendAdminNotification');
      await callable.call({
        'notificationId': docRef.id,
        'target': notification.target.name,
        'type': notification.type.name,
      });

      // Log successful notification trigger
      await _logAction(
        ActivityAction.notify, 
        ActivityModule.notifications, 
        docRef.id, 
        'Sent notification: ${notification.title} to ${notification.target.name}'
      );
    } catch (e) {
      await _logAction(
        ActivityAction.systemError, 
        ActivityModule.notifications, 
        docRef.id, 
        'Failed to send notification: ${notification.title}. Error: ${e.toString()}'
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    await _firestore.collection('admin_notifications').doc(id).delete();
    await _logAction(ActivityAction.delete, ActivityModule.notifications, id, 'Deleted historical notification');
  }

  Stream<List<AdminNotificationModel>> watchNotifications() {
    return _firestore
        .collection('admin_notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AdminNotificationModel.fromFirestore(doc)).toList());
  }

  Future<void> _logAction(ActivityAction action, ActivityModule module, String targetId, String description) async {
    await _logRepository.logAction(ActivityLogEntity(
      id: '',
      adminId: _adminId,
      adminEmail: _adminEmail,
      action: action,
      module: module,
      targetId: targetId,
      description: description,
      ipAddress: '0.0.0.0',
      timestamp: DateTime.now(),
    ));
  }
}
