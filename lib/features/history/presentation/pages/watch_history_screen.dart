import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/history_provider.dart';
import '../widgets/history_item_tile.dart';

class WatchHistoryScreen extends StatelessWidget {
  const WatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              // Implementation for Clear All if needed
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoadingWidget(message: 'Loading history...');
          }

          if (provider.historyItems.isEmpty) {
            return const AppErrorView(
              type: ErrorViewType.empty,
              title: 'No History',
              message: 'Movies you watch will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.s),
            itemCount: provider.historyItems.length,
            itemBuilder: (context, index) {
              final progress = provider.historyItems[index];
              return HistoryItemTile(
                progress: progress,
                onTap: () => context.push('/movie-details/${progress.movieId}'),
                onDelete: () => provider.clearItem(progress.movieId),
              );
            },
          );
        },
      ),
    );
  }
}
