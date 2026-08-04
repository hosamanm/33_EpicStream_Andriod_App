import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../../domain/repositories/admin_notification_repository.dart';

enum NotificationManagementStatus { initial, loading, loaded, error }

class AdminNotificationProvider extends ChangeNotifier {
  final AdminNotificationRepository _repository;
  StreamSubscription? _subscription;

  AdminNotificationProvider(this._repository);

  NotificationManagementStatus _status = NotificationManagementStatus.initial;
  NotificationManagementStatus get status => _status;

  List<AdminNotificationEntity> _notifications = [];
  List<AdminNotificationEntity> get notifications => _notifications;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void init() {
    _status = NotificationManagementStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchNotifications().listen((data) {
      _notifications = data;
      _status = NotificationManagementStatus.loaded;
      notifyListeners();
    }, onError: (error) {
      _errorMessage = error.toString();
      _status = NotificationManagementStatus.error;
      notifyListeners();
    });
  }

  Future<void> sendNotification(AdminNotificationEntity notification) async {
    final result = await _repository.sendNotification(notification);
    if (result.isError) {
      _errorMessage = result.failure.message;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(String id) async {
    final result = await _repository.deleteNotification(id);
    if (result.isError) {
      _errorMessage = result.failure.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
