import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../providers/category_provider.dart';
import '../controllers/category_management_controller.dart';
import '../widgets/category_form.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late CategoryManagementController _controller;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _controller = CategoryManagementController(context.read<CategoryProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init();
    });
  }

  void _showCategoryDialog([AdminCategoryEntity? category]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AdminColors.backgroundDark,
        child: Container(
          width: 800,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category == null ? 'Add New Platform Category' : 'Edit Category Metadata',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(height: 32, color: Colors.white10),
              CategoryForm(
                category: category,
                parentCategories: context.read<CategoryProvider>().categories,
                onSave: (updated, img, icon) {
                  if (category == null) {
                    context.read<CategoryProvider>().addCategory(updated, img: img, icon: icon);
                  } else {
                    context.read<CategoryProvider>().updateCategory(updated, img: img, icon: icon);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Organization'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('ADD CATEGORY'),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Column(
        children: [
          _buildTopBar(provider),
          if (_selectedIds.isNotEmpty) _buildBulkActionBar(provider),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildTopBar(CategoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AdminColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 24),
          _InfoChip(label: 'Global Categories', value: provider.categories.length.toString()),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(CategoryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
          color: AdminColors.primary.withValues(alpha: 0.1), 
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Text('${_selectedIds.length} items selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              provider.bulkToggleStatus(_selectedIds.toList(), true);
              setState(() => _selectedIds.clear());
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('ENABLE'),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () {
              provider.bulkToggleStatus(_selectedIds.toList(), false);
              setState(() => _selectedIds.clear());
            },
            icon: const Icon(Icons.block),
            label: const Text('DISABLE'),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => setState(() => _selectedIds.clear()),
            icon: const Icon(Icons.close),
            tooltip: 'Clear Selection',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CategoryProvider provider) {
    if (provider.status == CategoryManagementStatus.loading && provider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = provider.filteredCategories;
    if (list.isEmpty) return const Center(child: Text('No categories found matching search.'));

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: list.length,
      onReorder: (oldIdx, newIdx) {
        if (newIdx > oldIdx) newIdx -= 1;
        final items = List<AdminCategoryEntity>.from(list);
        final item = items.removeAt(oldIdx);
        items.insert(newIdx, item);
        _controller.onReorderCategories(items.map((e) => e.id).toList());
      },
      itemBuilder: (context, index) {
        final category = list[index];
        final isSelected = _selectedIds.contains(category.id);
        return _CategoryListItem(
          key: ValueKey(category.id),
          category: category,
          isSelected: isSelected,
          onSelect: () => _toggleSelection(category.id),
          onEdit: () => _showCategoryDialog(category),
          onDelete: () => _controller.onDeleteCategory(context, category.id),
          onToggle: (val) => context.read<CategoryProvider>().updateCategory(category.copyWith(isEnabled: val)),
        );
      },
    );
  }
}

class _CategoryListItem extends StatelessWidget {
  final AdminCategoryEntity category;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  const _CategoryListItem({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AdminColors.primary.withValues(alpha: 0.05) : AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AdminColors.primary.withValues(alpha: 0.3) : Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(value: isSelected, onChanged: (_) => onSelect(), activeColor: AdminColors.primary),
            const SizedBox(width: 8),
            const Icon(Icons.drag_indicator, color: Colors.white24),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(8)),
              child: category.iconUrl != null 
                ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(category.iconUrl!, fit: BoxFit.cover))
                : const Icon(Icons.category_outlined, color: Colors.white24),
            ),
          ],
        ),
        title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.white38)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: category.isEnabled, onChanged: onToggle, activeTrackColor: AdminColors.primary),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueAccent), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _InfoChip({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05), 
        borderRadius: BorderRadius.circular(20), 
        border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
