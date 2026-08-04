import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/admin_dimensions.dart';

class ImagePickerWidget extends StatefulWidget {
  final String label;
  final String? initialUrl;
  final Function(Uint8List? file) onImageSelected;
  final double aspectRatio;

  const ImagePickerWidget({
    super.key,
    required this.label,
    this.initialUrl,
    required this.onImageSelected,
    this.aspectRatio = 2 / 3,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  Uint8List? _selectedFileData;
  String? _fileName;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _selectedFileData = result.files.first.bytes;
        _fileName = result.files.first.name;
      });
      widget.onImageSelected(_selectedFileData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius:
                    BorderRadius.circular(AdminDimensions.radiusMedium),
                border: Border.all(color: Colors.white10),
              ),
              child: _selectedFileData != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AdminDimensions.radiusMedium),
                      child: Image.memory(_selectedFileData!, fit: BoxFit.cover),
                    )
                  : (widget.initialUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                              AdminDimensions.radiusMedium),
                          child: Image.network(widget.initialUrl!,
                              fit: BoxFit.cover),
                        )
                      : const Center(
                          child: Icon(Icons.add_photo_alternate_outlined,
                              size: 40, color: Colors.white24))),
            ),
          ),
        ),
      ],
    );
  }
}
