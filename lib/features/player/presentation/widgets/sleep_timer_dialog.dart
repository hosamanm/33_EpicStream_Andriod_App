import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/video_player_provider.dart';
import '../../data/services/advanced_player_service.dart';
import '../../../../core/di/injection.dart';

class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final advancedService = sl<AdvancedPlayerService>();
    final playerProvider = context.read<VideoPlayerProvider>();

    final options = [
      {'label': 'Off', 'value': 0},
      {'label': '10 Minutes', 'value': 10},
      {'label': '20 Minutes', 'value': 20},
      {'label': '30 Minutes', 'value': 30},
      {'label': '60 Minutes', 'value': 60},
      {'label': 'End of Episode', 'value': -1},
    ];

    return AlertDialog(
      title: const Text('Sleep Timer', style: TextStyle(color: Colors.white)),
      backgroundColor: AppColors.darkSurface,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          return ListTile(
            title: Text(opt['label'] as String, style: const TextStyle(color: Colors.white70)),
            onTap: () {
              final minutes = opt['value'] as int;
              if (minutes == 0) {
                advancedService.cancelSleepTimer();
              } else if (minutes > 0) {
                advancedService.setSleepTimer(
                  Duration(minutes: minutes),
                  playerProvider.betterPlayerController!,
                );
              }
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
