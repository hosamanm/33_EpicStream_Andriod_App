import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:epic_stream/core/theme/app_colors.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/core/widgets/loading_widget.dart';
import 'package:epic_stream/features/notifications/presentation/providers/notification_provider.dart';
import 'package:epic_stream/features/notifications/domain/entities/notification_history_entity.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Explicitly type the provider lookup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Mark all as read',
            onPressed: () => context.read<NotificationProvider>().markAllAsRead(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.status == NotificationStatus.loading) {
            return const AppLoadingWidget(message: 'Syncing notifications...');
          }

          if (provider.status == NotificationStatus.error) {
            return AppErrorView(
              message: provider.errorMessage ?? 'Failed to load notifications',
              onRetry: () => provider.init(),
            );
          }

          if (provider.notifications.isEmpty) {
            return const AppErrorView(
              type: ErrorViewType.empty,
              title: 'No Notifications',
              message: 'Stay tuned! We will notify you about new movies and updates.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
            itemCount: provider.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
            itemBuilder: (context, index) {
              final notification = provider.notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationHistoryEntity notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<NotificationProvider>().deleteNotification(notification.id);
      },
      child: ListTile(
        onTap: () {
          context.read<NotificationProvider>().markAsRead(notification.id);
        },
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.05),
              child: Icon(
                _getIconForType(notification.type),
                color: notification.isRead ? Colors.white38 : AppColors.primaryRed,
              ),
            ),
            if (!notification.isRead)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: notification.isRead ? Colors.white70 : Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: notification.isRead ? Colors.white38 : Colors.white60),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, hh:mm a').format(notification.createdAt),
              style: const TextStyle(fontSize: 10, color: Colors.white24),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_movie':
        return Icons.movie_outlined;
      case 'trailer':
        return Icons.play_circle_outline;
      case 'featured':
        return Icons.star_outline;
      case 'announcement':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }
}
