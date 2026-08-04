import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/categories_provider.dart';

/// A dialog to select the sorting criteria for movies/shows within a category.
class SortDialog extends StatelessWidget {
  const SortDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final options = ['Newest', 'Popular', 'Trending', 'A-Z'];

    return AlertDialog(
      title: const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = provider.selectedSort == option;
          return ListTile(
            title: Text(
              option,
              style: TextStyle(
                color: isSelected ? AppColors.primaryRed : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle, color: AppColors.primaryRed) 
                : null,
            onTap: () {
              provider.setSort(option);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
