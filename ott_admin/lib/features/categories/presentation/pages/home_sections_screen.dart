import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/home_section_entity.dart';
import '../providers/category_provider.dart';

class HomeSectionsScreen extends StatefulWidget {
  const HomeSectionsScreen({super.key});

  @override
  State<HomeSectionsScreen> createState() => _HomeSectionsScreenState();
}

class _HomeSectionsScreenState extends State<HomeSectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchHomeSections();
    });
  }

  void _showSectionDialog([HomeSectionEntity? section]) {
    final titleController = TextEditingController(text: section?.title);
    HomeSectionType selectedType = section?.type ?? HomeSectionType.grid;
    HomeSectionQuery selectedQuery = section?.queryType ?? HomeSectionQuery.latest;
    String? customQueryId = section?.customQueryId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(section == null ? 'Add Home Section' : 'Edit Home Section'),
          backgroundColor: AdminColors.surfaceDark,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Section Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<HomeSectionType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Display Type', border: OutlineInputBorder()),
                  items: HomeSectionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<HomeSectionQuery>(
                  value: selectedQuery,
                  decoration: const InputDecoration(labelText: 'Content Source', border: OutlineInputBorder()),
                  items: HomeSectionQuery.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase()))).toList(),
                  onChanged: (v) => setDialogState(() => selectedQuery = v!),
                ),
                if (selectedQuery == HomeSectionQuery.custom) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: customQueryId,
                    decoration: const InputDecoration(labelText: 'Select Category', border: OutlineInputBorder()),
                    items: context.read<CategoryProvider>().categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (v) => setDialogState(() => customQueryId = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newSection = HomeSectionEntity(
                    id: section?.id ?? '',
                    title: titleController.text.trim(),
                    type: selectedType,
                    queryType: selectedQuery,
                    customQueryId: customQueryId,
                    displayOrder: section?.displayOrder ?? 0,
                    isEnabled: section?.isEnabled ?? true,
                    createdAt: section?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  if (section == null) {
                    context.read<CategoryProvider>().addHomeSection(newSection);
                  } else {
                    context.read<CategoryProvider>().updateHomeSection(newSection);
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: Text(section == null ? 'ADD' : 'UPDATE'),
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
      appBar: AppBar(
        title: const Text('Home Content Layout'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showSectionDialog(),
            icon: const Icon(Icons.add),
            label: const Text('ADD SECTION'),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: provider.homeSections.isEmpty
          ? const Center(child: Text('No home sections defined.'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: provider.homeSections.length,
              onReorder: (oldIdx, newIdx) {
                if (newIdx > oldIdx) newIdx -= 1;
                final items = List<HomeSectionEntity>.from(provider.homeSections);
                final item = items.removeAt(oldIdx);
                items.insert(newIdx, item);
                provider.reorderHomeSections(items.map((e) => e.id).toList());
              },
              itemBuilder: (context, index) {
                final section = provider.homeSections[index];
                return Container(
                  key: ValueKey(section.id),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_indicator, color: Colors.white24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${section.type.name.toUpperCase()} • ${section.queryType.name.toUpperCase()}', 
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      Switch(
                        value: section.isEnabled, 
                        onChanged: (v) => context.read<CategoryProvider>().updateHomeSection(section.copyWith(isEnabled: v)),
                        activeColor: AdminColors.primary,
                      ),
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showSectionDialog(section)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => provider.deleteHomeSection(section.id),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
