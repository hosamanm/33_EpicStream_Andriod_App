import 'package:flutter/material.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../controllers/category_management_controller.dart';

class CategoryTable extends StatelessWidget {
  final List<AdminCategoryEntity> categories;
  final CategoryManagementController controller;

  const CategoryTable({
    super.key,
    required this.categories,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 24,
      headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
      columns: const [
        DataColumn(label: Text('Order', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Category Name', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: categories.map((category) {
        return DataRow(cells: [
          DataCell(Text('#${category.displayOrder}')),
          DataCell(Row(
            children: [
              if (category.iconUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    category.iconUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 18, color: Colors.white24),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          )),
          DataCell(_StatusBadge(isEnabled: category.isEnabled)),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueAccent),
                onPressed: () => controller.onEditCategory(context, category),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () => controller.onDeleteCategory(context, category.id),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isEnabled;
  const _StatusBadge({required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final color = isEnabled ? Colors.greenAccent : Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        isEnabled ? 'ENABLED' : 'DISABLED',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
