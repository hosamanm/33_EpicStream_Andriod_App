import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/admin_dimensions.dart';

class FilePickerWidget extends StatefulWidget {
  final String label;
  final List<String> allowedExtensions;
  final Function(List<PlatformFile> files) onFilesSelected;

  const FilePickerWidget({
    super.key,
    required this.label,
    this.allowedExtensions = const ['vtt', 'srt'],
    required this.onFilesSelected,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      allowMultiple: true,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files;
      });
      widget.onFilesSelected(_selectedFiles);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AdminDimensions.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AdminDimensions.radiusMedium),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                if (_selectedFiles.isEmpty)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subtitles_outlined, color: Colors.white24),
                      SizedBox(width: 8),
                      Text('Select Subtitle Files', style: TextStyle(color: Colors.white38)),
                    ],
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedFiles.map((file) => Chip(
                      label: Text(file.name, style: const TextStyle(fontSize: 10)),
                      backgroundColor: Colors.white12,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() {
                          _selectedFiles.remove(file);
                        });
                        widget.onFilesSelected(_selectedFiles);
                      },
                    )).toList(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
