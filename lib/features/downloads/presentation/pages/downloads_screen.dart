import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/download_provider.dart';
import '../../domain/entities/download_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DownloadProvider>().loadDownloads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('My Downloads', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<DownloadProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AppLoadingWidget(message: 'Retrieving your downloads...');
          }

          if (provider.items.isEmpty) {
            return AppEmptyView(
              icon: Icons.download_for_offline_outlined,
              title: 'No Downloads',
              message: 'Content you download for offline viewing will appear here.',
              actionLabel: 'Browse Content',
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.m),
            itemCount: provider.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.m),
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return _DownloadTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final DownloadItem item;
  const _DownloadTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppDimensions.radiusM)),
            child: CachedNetworkImage(
              imageUrl: item.posterUrl,
              width: 140,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.quality} • ${_formatBytes(item.sizeBytes)}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  if (item.status == DownloadStatus.downloading)
                    LinearProgressIndicator(
                      value: item.progress,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      minHeight: 2,
                    )
                  else
                    Text(
                      item.status == DownloadStatus.completed ? 'Watch Offline' : item.status.toString().split('.').last.toUpperCase(),
                      style: TextStyle(
                        color: item.status == DownloadStatus.completed ? Colors.green : AppColors.primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38),
            onPressed: () => context.read<DownloadProvider>().removeDownload(item.id),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return "${size.toStringAsFixed(1)} ${suffixes[i]}";
  }
}
