import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../domain/entities/age_rating_entity.dart';
import '../providers/category_provider.dart';

class AgeRatingScreen extends StatefulWidget {
  const AgeRatingScreen({super.key});

  @override
  State<AgeRatingScreen> createState() => _AgeRatingScreenState();
}

class _AgeRatingScreenState extends State<AgeRatingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().fetchAgeRatings();
    });
  }

  void _showRatingDialog([AgeRatingEntity? rating]) {
    final ratingController = TextEditingController(text: rating?.rating);
    final descController = TextEditingController(text: rating?.description);
    Uint8List? iconFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(rating == null ? 'Add Age Rating' : 'Edit Age Rating'),
          backgroundColor: AdminColors.surfaceDark,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: ratingController,
                decoration: const InputDecoration(labelText: 'Rating Label (e.g. U/A 16+)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ImagePickerWidget(
                label: 'Rating Badge Icon',
                initialUrl: rating?.iconUrl,
                aspectRatio: 1,
                onImageSelected: (bytes) => setDialogState(() => iconFile = bytes),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (ratingController.text.isNotEmpty) {
                  final newRating = AgeRatingEntity(
                    id: rating?.id ?? '',
                    rating: ratingController.text.trim(),
                    description: descController.text.trim(),
                    iconUrl: rating?.iconUrl,
                    displayOrder: rating?.displayOrder ?? 0,
                  );
                  context.read<CategoryProvider>().addAgeRating(newRating, icon: iconFile);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary),
              child: Text(rating == null ? 'ADD' : 'UPDATE'),
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
      appBar: AppBar(title: const Text('Age Ratings')),
      body: provider.ageRatings.isEmpty
          ? const Center(child: Text('No age ratings defined.'))
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: provider.ageRatings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rating = provider.ageRatings[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
                        child: rating.iconUrl != null 
                          ? Image.network(rating.iconUrl!)
                          : const Icon(Icons.explicit_outlined, color: Colors.white24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rating.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (rating.description != null)
                              Text(rating.description!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showRatingDialog(rating)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => provider.deleteAgeRating(rating.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRatingDialog(),
        backgroundColor: AdminColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
