import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/core/widgets/error_view.dart';
import 'package:epic_stream/core/widgets/loading_widget.dart';
import 'package:epic_stream/features/history/presentation/providers/continue_watching_provider.dart';
import 'package:epic_stream/features/history/presentation/widgets/continue_watching_card.dart';

class ContinueWatchingScreen extends StatelessWidget {
  const ContinueWatchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continue Watching', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<ContinueWatchingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoadingWidget(message: 'Retrieving playback sessions...');
          }

          if (provider.items.isEmpty) {
            return const AppErrorView(
              type: ErrorViewType.empty,
              title: 'Nothing to Continue',
              message: 'Pick up where you left off by watching a movie.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.m),
            itemCount: provider.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.m),
            itemBuilder: (context, index) {
              final progress = provider.items[index];
              return ContinueWatchingCard(
                progress: progress,
                onTap: () => context.push('/player/${progress.movieId}'),
                onInfo: () => context.push('/movie-details/${progress.movieId}'),
              );
            },
          );
        },
      ),
    );
  }
}
