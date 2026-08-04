import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../domain/entities/language_entity.dart';
import '../providers/category_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchLanguages();
    });
  }

  void _showLanguageDialog([LanguageEntity? language]) {
    final nameController = TextEditingController(text: language?.name);
    final codeController = TextEditingController(text: language?.code);
    Uint8List? iconFile;
    bool isDefault = language?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(language == null ? 'Add New Language' : 'Edit Language'),
          backgroundColor: AdminColors.surfaceDark,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Language Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Language Code (ISO 639-1)', border: OutlineInputBorder(), hintText: 'en'),
              ),
              const SizedBox(height: 24),
              ImagePickerWidget(
                label: 'Language Icon / Flag',
                initialUrl: language?.iconUrl,
                aspectRatio: 1,
                onImageSelected: (bytes) => setDialogState(() => iconFile = bytes),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Set as Default Language', style: TextStyle(fontSize: 14)),
                value: isDefault,
                onChanged: (val) => setDialogState(() => isDefault = val ?? false),
                activeColor: AdminColors.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && codeController.text.isNotEmpty) {
                  final newLang = LanguageEntity(
                    id: language?.id ?? '',
                    name: nameController.text.trim(),
                    code: codeController.text.trim().toLowerCase(),
                    iconUrl: language?.iconUrl,
                    isDefault: isDefault,
                    isEnabled: language?.isEnabled ?? true,
                    displayOrder: language?.displayOrder ?? 0,
                  );
                  context.read<CategoryProvider>().addLanguage(newLang, icon: iconFile);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: Text(language == null ? 'ADD' : 'UPDATE'),
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
      appBar: AppBar(title: const Text('Language Management')),
      body: provider.languages.isEmpty
          ? const Center(child: Text('No languages configured.'))
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.2,
              ),
              itemCount: provider.languages.length,
              itemBuilder: (context, index) {
                final lang = provider.languages[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: lang.isDefault ? AdminColors.primary.withOpacity(0.5) : Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: lang.iconUrl != null 
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(lang.iconUrl!, fit: BoxFit.cover))
                          : Center(child: Text(lang.code.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            if (lang.isDefault)
                              const Text('DEFAULT', style: TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () => _showLanguageDialog(lang)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () => provider.deleteLanguage(lang.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLanguageDialog(),
        backgroundColor: AdminColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
