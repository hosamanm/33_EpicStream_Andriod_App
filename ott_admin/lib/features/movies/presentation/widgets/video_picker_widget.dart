import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';

class VideoPickerWidget extends StatefulWidget {
  final String label;
  final String? initialUrl;
  final Function(Uint8List? file) onVideoSelected;

  const VideoPickerWidget({
    super.key,
    required this.label,
    this.initialUrl,
    required this.onVideoSelected,
  });

  @override
  State<VideoPickerWidget> createState() => _VideoPickerWidgetState();
}

class _VideoPickerWidgetState extends State<VideoPickerWidget> {
  Uint8List? _selectedFileData;
  String? _fileName;
  String? _fileSize;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );

    if (result != null && result.files.first.bytes != null) {
      final file = result.files.first;
      setState(() {
        _selectedFileData = file.bytes;
        _fileName = file.name;
        _fileSize = '${(file.size / (1024 * 1024)).toStringAsFixed(2)} MB';
      });
      widget.onVideoSelected(_selectedFileData);
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
          onTap: _pickVideo,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AdminDimensions.paddingLarge),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AdminDimensions.paddingMedium),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.movie_creation_outlined, size: 40, color: Colors.white24),
                const SizedBox(width: AdminDimensions.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fileName ?? (widget.initialUrl != null ? 'Existing Video Attached' : 'Select Video File'),
                        style: TextStyle(
                          color: _fileName != null ? Colors.white : Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_fileSize != null)
                        Text(_fileSize!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
                if (_selectedFileData != null)
                  const Icon(Icons.check_circle, color: Colors.greenAccent)
                else
                  const Icon(Icons.upload_file, color: Colors.white24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
