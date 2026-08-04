import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_history_model.dart';
import '../models/notification_settings_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationHistoryModel>> watchNotificationHistory(String userId);
  Future<void> markAsRead(String historyId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String historyId);
  Future<int> getUnreadCount(String userId);
  Future<void> updateFcmToken(String userId, String token);
  Future<void> updateNotificationSettings(NotificationSettingsModel settings);
  Future<NotificationSettingsModel?> getNotificationSettings(String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl(this._firestore);

  CollectionReference get _historyCol => _firestore.collection('notification_history');
  CollectionReference get _settingsCol => _firestore.collection('user_notification_settings');
  CollectionReference get _usersCol => _firestore.collection('users');

  @override
  Stream<List<NotificationHistoryModel>> watchNotificationHistory(String userId) {
    return _historyCol
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationHistoryModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<void> markAsRead(String historyId) async {
    await _historyCol.doc(historyId).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
      'clickedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final unread = await _historyCol
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
        
    final batch = _firestore.batch();
    for (var doc in unread.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String historyId) async {
    await _historyCol.doc(historyId).delete();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await _historyCol
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    // Primary token on user doc
    await _usersCol.doc(userId).update({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Multi-device tracking
    await _usersCol.doc(userId).collection('tokens').doc(token).set({
      'token': token,
      'platform': 'android',
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateNotificationSettings(NotificationSettingsModel settings) async {
    await _settingsCol.doc(settings.userId).set(
      settings.toFirestore(),
      SetOptions(merge: true),
    );
  }

  @override
  Future<NotificationSettingsModel?> getNotificationSettings(String userId) async {
    final doc = await _settingsCol.doc(userId).get();
    if (!doc.exists) return null;
    return NotificationSettingsModel.fromFirestore(doc);
  }
}
