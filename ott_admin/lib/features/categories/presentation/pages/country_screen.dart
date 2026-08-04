import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../domain/entities/country_entity.dart';
import '../providers/category_provider.dart';
import '../controllers/category_management_controller.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  late CategoryManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryManagementController(context.read<CategoryProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchCountries();
    });
  }

  void _showAddCountryDialog([CountryEntity? country]) {
    final nameController = TextEditingController(text: country?.name);
    final codeController = TextEditingController(text: country?.code);
    Uint8List? flagFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(country == null ? 'Add New Country' : 'Edit Country'),
          backgroundColor: AdminColors.surfaceDark,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Country Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'ISO Alpha-2 Code (e.g. US, IN)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ImagePickerWidget(
                label: 'Country Flag',
                initialUrl: country?.flagUrl,
                aspectRatio: 3 / 2,
                onImageSelected: (bytes) => setDialogState(() => flagFile = bytes),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                  final newCountry = CountryEntity(
                    id: country?.id ?? '',
                    name: nameController.text.trim(),
                    code: codeController.text.trim().toUpperCase(),
                    isEnabled: country?.isEnabled ?? true,
                    displayOrder: country?.displayOrder ?? 0,
                  );
                  context.read<CategoryProvider>().addCountry(newCountry, flag: flagFile);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: Text(country == null ? 'ADD' : 'UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Country Management')),
      body: provider.countries.isEmpty
          ? const Center(child: Text('No countries configured.'))
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: provider.countries.length,
              itemBuilder: (context, index) {
                final country = provider.countries[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 32,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                        child: country.flagUrl != null 
                          ? Image.network(country.flagUrl!, fit: BoxFit.cover)
                          : Center(child: Text(country.code, style: const TextStyle(fontSize: 10))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(country.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            Text(country.code, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showAddCountryDialog(country)),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCountryDialog(),
        backgroundColor: AdminColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
