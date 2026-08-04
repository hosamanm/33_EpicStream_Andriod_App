import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/admin_notification_entity.dart';
import '../providers/admin_notification_provider.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() => _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminNotificationProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminNotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AdminNotificationProvider provider) {
    if (provider.status == NotificationManagementStatus.loading && provider.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == NotificationManagementStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.init(),
      );
    }

    if (provider.notifications.isEmpty) {
      return const Center(child: Text('No notification history found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.notifications.length,
      itemBuilder: (context, index) {
        final notification = provider.notifications[index];
        return _NotificationHistoryCard(
          notification: notification,
          onDelete: () => provider.deleteNotification(notification.id),
        );
      },
    );
  }
}

class _NotificationHistoryCard extends StatelessWidget {
  final AdminNotificationEntity notification;
  final VoidCallback onDelete;

  const _NotificationHistoryCard({required this.notification, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        leading: _buildStatusIcon(),
        title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Sent to: ${notification.target.name.toUpperCase()} • ${notification.createdAt.toString().split('.')[0]}',
          style: const TextStyle(fontSize: 12, color: Colors.white38),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
          onPressed: onDelete,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: 'SENT', value: notification.sentCount.toString(), color: Colors.blueAccent),
                    _StatItem(label: 'OPENED', value: notification.openedCount.toString(), color: Colors.greenAccent),
                    _StatItem(
                      label: 'CTR', 
                      value: notification.sentCount > 0 
                        ? '${((notification.openedCount / notification.sentCount) * 100).toStringAsFixed(1)}%' 
                        : '0%', 
                      color: Colors.amber,
                    ),
                  ],
                ),
                if (notification.deepLinkType != null) ...[
                  const Divider(height: 32, color: Colors.white10),
                  Text(
                    'Deep Link: ${notification.deepLinkType} (${notification.deepLinkValue})',
                    style: const TextStyle(fontSize: 12, color: Colors.white24),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (notification.status) {
      case AdminNotificationStatus.sent:
        return const Icon(Icons.check_circle_outline, color: Colors.greenAccent);
      case AdminNotificationStatus.sending:
        return const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case AdminNotificationStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.redAccent);
      case AdminNotificationStatus.pending:
      default:
        return const Icon(Icons.access_time, color: Colors.orangeAccent);
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white38, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
