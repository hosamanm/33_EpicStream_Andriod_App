import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../domain/entities/genre_entity.dart';
import '../providers/category_provider.dart';
import '../controllers/category_management_controller.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  late CategoryManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CategoryManagementController(context.read<CategoryProvider>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchGenres();
    });
  }

  void _showGenreDialog([GenreEntity? genre]) {
    final nameController = TextEditingController(text: genre?.name);
    Uint8List? selectedImage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(genre == null ? 'Add New Genre' : 'Edit Genre'),
          backgroundColor: AdminColors.surfaceDark,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Genre Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ImagePickerWidget(
                label: 'Genre Image',
                initialUrl: genre?.imageUrl,
                aspectRatio: 1,
                onImageSelected: (bytes) {
                  setDialogState(() => selectedImage = bytes);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newGenre = GenreEntity(
                    id: genre?.id ?? '',
                    name: nameController.text.trim(),
                    imageUrl: genre?.imageUrl,
                    isEnabled: genre?.isEnabled ?? true,
                    displayOrder: genre?.displayOrder ?? 0,
                    createdAt: genre?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  if (genre == null) {
                    context.read<CategoryProvider>().addGenre(newGenre, image: selectedImage);
                  } else {
                    context.read<CategoryProvider>().updateGenre(newGenre, image: selectedImage);
                  }
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: Text(genre == null ? 'ADD' : 'UPDATE'),
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
        title: const Text('Genre Management'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showGenreDialog(),
            icon: const Icon(Icons.add),
            label: const Text('ADD GENRE'),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: provider.genres.isEmpty
          ? const Center(child: Text('No genres found.'))
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.8,
              ),
              itemCount: provider.genres.length,
              itemBuilder: (context, index) => _GenreCard(
                genre: provider.genres[index],
                onEdit: () => _showGenreDialog(provider.genres[index]),
                onDelete: () => context.read<CategoryProvider>().deleteGenre(provider.genres[index].id),
              ),
            ),
    );
  }
}

class _GenreCard extends StatelessWidget {
  final GenreEntity genre;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GenreCard({required this.genre, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                width: double.infinity,
                color: Colors.white10,
                child: genre.imageUrl != null 
                    ? Image.network(genre.imageUrl!, fit: BoxFit.cover)
                    : const Icon(Icons.style, size: 48, color: Colors.white24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(genre.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(genre.isEnabled ? 'ENABLED' : 'DISABLED', 
                        style: TextStyle(color: genre.isEnabled ? Colors.greenAccent : Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                        const SizedBox(width: 8),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: onDelete, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
