import 'package:flutter/material.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../providers/admin_notification_provider.dart';

/// Controller for the Notification Center UI logic.
/// Decouples the UI from the provider state updates.
class AdminNotificationController {
  final AdminNotificationProvider _provider;

  AdminNotificationController(this._provider);

  Future<void> init() async {
    _provider.init();
  }

  Future<void> onSendNotification(AdminNotificationEntity notification) async {
    await _provider.sendNotification(notification);
  }

  Future<void> onDeleteNotification(String id) async {
    await _provider.deleteNotification(id);
  }
}
