import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/categories_provider.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.l),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusL)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => provider.resetFilters(),
                  child: const Text('Reset All', style: TextStyle(color: AppColors.primaryRed)),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: AppDimensions.m),

            // Language Filter
            _buildDropdown(
              label: 'Language',
              value: provider.selectedLanguage,
              items: provider.languages,
              onChanged: (val) {
                provider.selectedLanguage = val;
                provider.notifyListeners();
              },
            ),

            // Country Filter
            _buildDropdown(
              label: 'Country',
              value: provider.selectedCountry,
              items: provider.countries,
              onChanged: (val) {
                provider.selectedCountry = val;
                provider.notifyListeners();
              },
            ),

            // Year Filter
            _buildDropdown(
              label: 'Release Year',
              value: provider.selectedYear,
              items: provider.years,
              onChanged: (val) {
                provider.selectedYear = val;
                provider.notifyListeners();
              },
            ),

            const SizedBox(height: AppDimensions.m),

            // Rating Filter
            Text('Minimum IMDb Rating', style: theme.textTheme.labelLarge),
            Slider(
              value: provider.minRating,
              min: 0,
              max: 10,
              divisions: 10,
              label: provider.minRating.toString(),
              activeColor: AppColors.primaryRed,
              onChanged: (val) => provider.updateRating(val),
            ),

            const SizedBox(height: AppDimensions.l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  provider.applyFilters();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.m),
                ),
                child: const Text('APPLY FILTERS'),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text('Select $label', style: const TextStyle(color: Colors.white38)),
            dropdownColor: AppColors.darkSurface,
            underline: Container(height: 1, color: Colors.white24),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
