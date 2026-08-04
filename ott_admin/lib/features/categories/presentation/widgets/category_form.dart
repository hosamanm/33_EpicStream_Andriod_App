import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/presentation/widgets/image_picker_widget.dart';
import '../../domain/entities/admin_category_entity.dart';

class CategoryForm extends StatefulWidget {
  final AdminCategoryEntity? category;
  final List<AdminCategoryEntity> parentCategories;
  final Function(AdminCategoryEntity category, Uint8List? image, Uint8List? icon) onSave;

  const CategoryForm({
    super.key,
    this.category,
    required this.parentCategories,
    required this.onSave,
  });

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  bool _isEnabled = true;
  
  Uint8List? _selectedImage;
  Uint8List? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descController = TextEditingController(text: widget.category?.description ?? '');
    _isEnabled = widget.category?.isEnabled ?? true;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final category = AdminCategoryEntity(
        id: widget.category?.id ?? '',
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: widget.category?.imageUrl,
        iconUrl: widget.category?.iconUrl,
        isEnabled: _isEnabled,
        displayOrder: widget.category?.displayOrder ?? 0,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      widget.onSave(category, _selectedImage, _selectedIcon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    ImagePickerWidget(
                      label: 'Category Banner',
                      initialUrl: widget.category?.imageUrl,
                      aspectRatio: 16 / 9,
                      onImageSelected: (bytes) => setState(() => _selectedImage = bytes),
                    ),
                    const SizedBox(height: 16),
                    ImagePickerWidget(
                      label: 'Category Icon',
                      initialUrl: widget.category?.iconUrl,
                      aspectRatio: 1,
                      onImageSelected: (bytes) => setState(() => _selectedIcon = bytes),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Category Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Enable Category'),
                      subtitle: const Text('Visible on mobile apps if enabled'),
                      value: _isEnabled,
                      onChanged: (val) => setState(() => _isEnabled = val),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('SAVE CATEGORY & UPLOAD ASSETS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
