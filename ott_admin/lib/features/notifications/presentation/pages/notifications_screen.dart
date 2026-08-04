import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';
import '../providers/admin_notification_provider.dart';
import '../widgets/notification_form.dart';
import 'notification_history_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()),
              );
            },
            icon: const Icon(Icons.history, size: 18),
            label: const Text('VIEW HISTORY'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compose New Notification',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Send push notifications to targeted user segments. Ensure deep links are valid.',
                        style: TextStyle(color: Colors.white54),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AdminColors.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: NotificationForm(
                          onSaved: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notification task created successfully.')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: _buildGuidelines(theme),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelines(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivery Guidelines', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _GuidelineItem(
          icon: Icons.timer_outlined,
          title: 'Immediate vs Scheduled',
          description: 'Immediate notifications are processed within 5-10 minutes. Scheduled ones are batched daily.',
        ),
        _GuidelineItem(
          icon: Icons.image_outlined,
          title: 'Image Specifications',
          description: 'Recommended size is 1200x600px. Large images may fail delivery on slow networks.',
        ),
        _GuidelineItem(
          icon: Icons.link_outlined,
          title: 'Deep Linking',
          description: 'Target IDs must exist in the production database. Test links in the staging app first.',
        ),
        _GuidelineItem(
          icon: Icons.people_outline,
          title: 'Audience Segments',
          description: 'Targeting by country or language uses ISO standard codes (e.g., US, EN).',
        ),
      ],
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuidelineItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AdminColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.white38, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
