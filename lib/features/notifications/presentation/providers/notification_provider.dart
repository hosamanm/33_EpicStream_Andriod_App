import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/notification_history_entity.dart';
import '../../domain/repositories/notification_repository.dart';

enum NotificationStatus { initial, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;
  StreamSubscription? _subscription;

  NotificationProvider(this._repository);

  NotificationStatus _status = NotificationStatus.initial;
  NotificationStatus get status => _status;

  List<NotificationHistoryEntity> _notifications = [];
  List<NotificationHistoryEntity> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void init() {
    if (_status == NotificationStatus.loading) return;
    
    _status = NotificationStatus.loading;
    _subscription?.cancel();
    
    _subscription = _repository.watchNotificationHistory().listen(
      (data) {
        _notifications = data;
        _unreadCount = data.where((n) => !n.isRead).length;
        _status = NotificationStatus.loaded;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _status = NotificationStatus.error;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String historyId) async {
    await _repository.markAsRead(historyId);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
  }

  Future<void> deleteNotification(String historyId) async {
    await _repository.deleteNotification(historyId);
  }

  Future<void> refreshUnreadCount() async {
    final result = await _repository.getUnreadCount();
    if (result.isSuccess) {
      _unreadCount = result.data!;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
