import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../providers/activity_log_provider.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityLogProvider>().fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityLogProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Audit Trail & Activity Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => provider.fetchLogs(refresh: true),
          ),
          const SizedBox(width: 8),
          _FilterButton(provider: provider),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showExportDialog(context),
            icon: const Icon(Icons.download),
            label: const Text('EXPORT'),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(ActivityLogProvider provider) {
    if (provider.status == ActivityLogStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == ActivityLogStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchLogs(refresh: true),
      );
    }

    if (provider.logs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white24),
            SizedBox(height: 16),
            Text('No activity logs found', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (provider.filterModule != null || provider.filterAction != null || provider.filterDateRange != null)
          _ActiveFiltersToolbar(provider: provider),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: provider.logs.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final log = provider.logs[index];
              return _LogItem(log: log);
            },
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Audit Logs'),
        content: const Text('Choose format for exporting activity logs:'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('CSV')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('PDF')),
        ],
      ),
    );
  }
}

class _LogItem extends StatelessWidget {
  final ActivityLogEntity log;
  const _LogItem({required this.log});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM dd, yyyy HH:mm:ss').format(log.timestamp);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionIcon(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.adminEmail,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AdminColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.module.name.toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ),
                    const Spacer(),
                    Text(timeStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(log.description, style: const TextStyle(color: Colors.white)),
                if (log.targetId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Target ID: ${log.targetId}', style: const TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(log.ipAddress, style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionIcon() {
    IconData iconData;
    Color color;

    switch (log.action) {
      case ActivityAction.upload:
      case ActivityAction.publish:
        iconData = Icons.cloud_upload;
        color = Colors.green;
        break;
      case ActivityAction.delete:
        iconData = Icons.delete_forever;
        color = Colors.red;
        break;
      case ActivityAction.edit:
        iconData = Icons.edit;
        color = Colors.orange;
        break;
      case ActivityAction.login:
        iconData = Icons.login;
        color = Colors.blue;
        break;
      case ActivityAction.securityAlert:
      case ActivityAction.systemError:
        iconData = Icons.warning;
        color = Colors.redAccent;
        break;
      default:
        iconData = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final ActivityLogProvider provider;
  const _FilterButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.filter_list),
      onPressed: () => _showFilterSheet(context),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Simplified filter implementation
    showModalBottomSheet(
      context: context,
      backgroundColor: AdminColors.surfaceDark,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Logs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Filter implementation placeholders
            const Text('Module', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 8),
            // ... dropdowns etc
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('APPLY FILTERS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveFiltersToolbar extends StatelessWidget {
  final ActivityLogProvider provider;
  const _ActiveFiltersToolbar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      color: Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 16, color: AdminColors.primary),
          const SizedBox(width: 8),
          const Text('Active Filters:', style: TextStyle(fontSize: 12, color: Colors.white54)),
          const SizedBox(width: 8),
          // chips...
          const Spacer(),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: const Text('CLEAR ALL', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
