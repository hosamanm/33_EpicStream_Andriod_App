import 'package:flutter/material.dart';
import '../../domain/entities/admin_category_entity.dart';
import '../../domain/entities/genre_entity.dart';
import '../providers/category_provider.dart';

class CategoryManagementController {
  final CategoryProvider _provider;

  CategoryManagementController(this._provider);

  Future<void> init() async {
    await _provider.init();
  }

  // --- Categories ---
  void onEditCategory(BuildContext context, AdminCategoryEntity category) {
    // Handled by CategoriesScreen dialog
  }

  Future<void> onDeleteCategory(BuildContext context, String id) async {
    final confirmed = await _showConfirmDialog(context, 'Delete Category', 'Movies in this category will become uncategorized.');
    if (confirmed) await _provider.deleteCategory(id);
  }

  // --- Genres ---
  Future<void> onAddGenre(BuildContext context, String name) async {
    final genre = GenreEntity(
      id: '',
      name: name,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _provider.addGenre(genre);
  }

  Future<void> onDeleteGenre(String id) async {
    await _provider.deleteGenre(id);
  }

  // --- Reordering Logic ---
  Future<void> onReorderCategories(List<String> ids) async {
    await _provider.reorderCategories(ids);
  }

  Future<void> onReorderHomeSections(List<String> ids) async {
    await _provider.reorderHomeSections(ids);
  }

  // --- Utilities ---
  Future<bool> _showConfirmDialog(BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('PROCEED', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    ) ?? false;
  }
}
