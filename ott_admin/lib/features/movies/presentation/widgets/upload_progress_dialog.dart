import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';
import '../providers/movie_upload_provider.dart';

/// A dialog that visualizes the multi-file upload process for a movie.
class UploadProgressDialog extends StatelessWidget {
  const UploadProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieUploadProvider>();
    final progressMap = provider.progressMap;

    return AlertDialog(
      backgroundColor: AdminColors.surfaceDark,
      title: const Text('Uploading Content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Task: ${provider.currentTask ?? 'Starting...'}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: AdminDimensions.paddingLarge),
          ...progressMap.entries.map((entry) => _ProgressItem(
                name: entry.key,
                progress: entry.value,
              )),
          if (progressMap.isEmpty)
            const Center(child: CircularProgressIndicator.adaptive()),
        ],
      ),
      actions: [
        if (!provider.isUploading)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE', style: TextStyle(color: AdminColors.primary)),
          ),
      ],
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String name;
  final double progress;

  const _ProgressItem({required this.name, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AdminDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.greenAccent : AdminColors.primary,
            ),
            minHeight: 4,
          ),
        ],
      ),
    );
  }
}
