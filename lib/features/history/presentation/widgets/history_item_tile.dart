import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/playback_progress_entity.dart';

class HistoryItemTile extends StatelessWidget {
  final PlaybackProgressEntity progress;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const HistoryItemTile({
    super.key,
    required this.progress,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(child: Icon(Icons.movie_outlined, color: Colors.white38)),
      ),
      title: Text(
        'Movie ID: ${progress.movieId}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progress.isCompleted ? 'Completed' : 'Watched ${progress.percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              color: progress.isCompleted ? Colors.green : Colors.white54,
              fontSize: 12,
            ),
          ),
          Text(
            DateFormat('MMM dd, yyyy • HH:mm').format(progress.lastPlayedTime),
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
        onPressed: onDelete,
      ),
    );
  }
}
