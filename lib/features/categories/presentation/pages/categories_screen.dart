import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/core/theme/app_dimensions.dart';
import 'package:epic_stream/features/categories/presentation/providers/categories_provider.dart';
import 'package:epic_stream/features/categories/presentation/widgets/category_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fixed: Method name changed from loadCategories to loadInitialData
      context.read<CategoriesProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : GridView.builder(
              padding: const EdgeInsets.all(AppDimensions.m),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: AppDimensions.m,
                mainAxisSpacing: AppDimensions.m,
              ),
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                final category = provider.categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () {
                    // Placeholder for category selection logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${category.name}')),
                    );
                  },
                );
              },
            ),
    );
  }
}
