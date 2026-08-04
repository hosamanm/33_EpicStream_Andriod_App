import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';
import '../../../../core/widgets/error_view.dart';
import '../providers/banner_provider.dart';
import '../controllers/banner_controller.dart';
import '../widgets/banner_form.dart';
import '../widgets/banner_slider_preview.dart';
import '../../domain/entities/admin_banner_entity.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  late BannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BannerController(context.read<AdminBannerProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  void _showBannerDialog([AdminBannerEntity? banner]) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 900,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    banner == null ? 'Add New Banner' : 'Edit Banner',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),
              Flexible(
                child: BannerForm(
                  banner: banner,
                  onSaved: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBannerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showBannerDialog(),
            icon: const Icon(Icons.add),
            label: const Text('ADD BANNER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(AdminBannerProvider provider) {
    if (provider.status == BannerManagementStatus.loading && provider.banners.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == BannerManagementStatus.error) {
      return AppErrorView(
        message: provider.errorMessage,
        onRetry: () => provider.fetchBanners(),
      );
    }

    if (provider.banners.isEmpty) {
      return const Center(child: Text('No banners found. Add your first banner!'));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. List / Reorderable Section
        Expanded(
          flex: 6,
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: provider.banners.length,
            onReorder: _controller.onReorder,
            itemBuilder: (context, index) {
              final banner = provider.banners[index];
              return _BannerListTile(
                key: ValueKey(banner.id),
                banner: banner,
                onEdit: () => _showBannerDialog(banner),
                onDelete: () => _controller.onDelete(banner.id),
              );
            },
          ),
        ),
        
        const VerticalDivider(width: 1),

        // 2. Live Preview Section
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LIVE PREVIEW (Desktop)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 24),
                if (provider.banners.isNotEmpty)
                  BannerSliderPreview(banner: provider.banners.first) // Shows the highest priority one
                else
                  const Center(child: Text('Add a banner to see preview')),
                const SizedBox(height: 32),
                const Text('Quick Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('Total Banners: ', style: TextStyle(color: Colors.white70)),
                // Additional settings could go here
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerListTile extends StatelessWidget {
  final AdminBannerEntity banner;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BannerListTile({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(banner.mobileImageUrl, width: 60, height: 40, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 60, height: 40, color: Colors.grey[800], child: const Icon(Icons.image, size: 20))),
        ),
        title: Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${banner.type.name.toUpperCase()} • ${banner.status.name.toUpperCase()}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator, color: Colors.white24),
            const SizedBox(width: 12),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueAccent), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
