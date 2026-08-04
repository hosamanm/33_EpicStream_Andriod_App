import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import 'image_picker_widget.dart';
import 'video_picker_widget.dart';
import 'file_picker_widget.dart';

class MovieForm extends StatefulWidget {
  final AdminMovieEntity? movie;
  final Function(Map<String, dynamic> data) onSave;

  const MovieForm({super.key, this.movie, required this.onSave});

  @override
  State<MovieForm> createState() => _MovieFormState();
}

class _MovieFormState extends State<MovieForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _originalTitleController;
  late TextEditingController _shortDescController;
  late TextEditingController _longDescController;
  late TextEditingController _releaseDateController;
  late TextEditingController _durationController;
  late TextEditingController _imdbController;
  late TextEditingController _directorController;
  late TextEditingController _producerController;
  late TextEditingController _writerController;
  late TextEditingController _musicDirectorController;
  late TextEditingController _countryController;

  String? _selectedCategoryId;
  List<String> _selectedGenreIds = [];
  String _selectedLanguage = 'en';
  String _ageRating = 'U/A 13+';
  AdminMovieStatus _status = AdminMovieStatus.draft;
  
  bool _isFeatured = false;
  bool _isTrending = false;
  bool _isEditorsChoice = false;

  Uint8List? _posterFile;
  Uint8List? _bannerFile;
  Uint8List? _logoFile;
  Uint8List? _thumbnailFile;
  Uint8List? _videoFile;
  Uint8List? _trailerFile;
  List<Uint8List> _subtitleFiles = [];

  List<Map<String, String>> _cast = [];
  List<Map<String, String>> _crew = [];
  List<Map<String, String>> _audioTracks = [];

  @override
  void initState() {
    super.initState();
    final m = widget.movie;
    _titleController = TextEditingController(text: m?.title);
    _originalTitleController = TextEditingController(text: m?.originalTitle);
    _shortDescController = TextEditingController(text: m?.shortDescription);
    _longDescController = TextEditingController(text: m?.description);
    _releaseDateController = TextEditingController(text: m?.releaseDate);
    _durationController = TextEditingController(text: m?.duration.toString());
    _imdbController = TextEditingController(text: m?.imdbRating.toString());
    _directorController = TextEditingController(text: m?.director);
    _producerController = TextEditingController(text: m?.producer);
    _writerController = TextEditingController(text: m?.writer);
    _musicDirectorController = TextEditingController(text: m?.musicDirector);
    _countryController = TextEditingController(text: m?.country);
    
    _selectedCategoryId = m?.categoryIds.isNotEmpty == true ? m?.categoryIds.first : null;
    _selectedGenreIds = List.from(m?.genreIds ?? []);
    _selectedLanguage = m?.language ?? 'en';
    _ageRating = m?.ageRating ?? 'U/A 13+';
    _status = m?.status ?? AdminMovieStatus.draft;
    _isFeatured = m?.isFeatured ?? false;
    _isTrending = m?.isTrending ?? false;
    _isEditorsChoice = m?.isEditorsChoice ?? false;
    _cast = List.from(m?.cast ?? []);
    _crew = List.from(m?.crew ?? []);
    _audioTracks = List.from(m?.audioTracks ?? []);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final movie = AdminMovieEntity(
        id: widget.movie?.id ?? '',
        title: _titleController.text.trim(),
        originalTitle: _originalTitleController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        description: _longDescController.text.trim(),
        posterUrl: widget.movie?.posterUrl ?? '',
        bannerUrl: widget.movie?.bannerUrl ?? '',
        logoUrl: widget.movie?.logoUrl,
        thumbnailUrl: widget.movie?.thumbnailUrl,
        movieVideoId: widget.movie?.movieVideoId,
        moviePlaybackUrl: widget.movie?.moviePlaybackUrl,
        trailerVideoId: widget.movie?.trailerVideoId,
        trailerPlaybackUrl: widget.movie?.trailerPlaybackUrl,
        categoryIds: _selectedCategoryId != null ? [_selectedCategoryId!] : [],
        genreIds: _selectedGenreIds,
        language: _selectedLanguage,
        country: _countryController.text.trim(),
        duration: int.tryParse(_durationController.text) ?? 0,
        releaseDate: _releaseDateController.text.trim(),
        ageRating: _ageRating,
        imdbRating: double.tryParse(_imdbController.text) ?? 0.0,
        director: _directorController.text.trim(),
        producer: _producerController.text.trim(),
        writer: _writerController.text.trim(),
        musicDirector: _musicDirectorController.text.trim(),
        cast: _cast,
        crew: _crew,
        audioTracks: _audioTracks,
        status: _status,
        isFeatured: _isFeatured,
        isTrending: _isTrending,
        isEditorsChoice: _isEditorsChoice,
        createdAt: widget.movie?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSave({
        'movie': movie,
        'poster': _posterFile,
        'banner': _bannerFile,
        'logo': _logoFile,
        'thumbnail': _thumbnailFile,
        'video': _videoFile,
        'trailer': _trailerFile,
        'subtitles': _subtitleFiles.isNotEmpty ? _subtitleFiles : null,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Basic Information'),
            _buildBasicInfo(),
            const SizedBox(height: 48),
            _buildSectionHeader('Media Assets'),
            _buildMediaAssets(),
            const SizedBox(height: 48),
            _buildSectionHeader('Video Content (Cloudflare Stream)'),
            _buildVideoUploads(),
            const SizedBox(height: 48),
            _buildSectionHeader('Metadata & Taxonomy'),
            _buildTaxonomy(),
            const SizedBox(height: 48),
            _buildSectionHeader('Cast & Crew'),
            _buildCastCrewSection(),
            const SizedBox(height: 48),
            _buildSectionHeader('Publishing Options'),
            _buildPublishingOptions(),
            const SizedBox(height: 64),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('Movie Title', _titleController)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Original Title', _originalTitleController)),
          ],
        ),
        const SizedBox(height: 24),
        _buildTextField('Short Description', _shortDescController, maxLines: 2),
        const SizedBox(height: 24),
        _buildTextField('Long Description', _longDescController, maxLines: 5),
      ],
    );
  }

  Widget _buildMediaAssets() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ImagePickerWidget(label: 'Poster (2:3)', initialUrl: widget.movie?.posterUrl, onImageSelected: (file) => setState(() => _posterFile = file))),
        const SizedBox(width: 24),
        Expanded(child: ImagePickerWidget(label: 'Banner (16:9)', initialUrl: widget.movie?.bannerUrl, aspectRatio: 16 / 9, onImageSelected: (file) => setState(() => _bannerFile = file))),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [
              ImagePickerWidget(label: 'Logo (PNG)', initialUrl: widget.movie?.logoUrl, aspectRatio: 3 / 1, onImageSelected: (file) => setState(() => _logoFile = file)),
              const SizedBox(height: 24),
              ImagePickerWidget(label: 'Thumbnail', initialUrl: widget.movie?.thumbnailUrl, aspectRatio: 4 / 3, onImageSelected: (file) => setState(() => _thumbnailFile = file)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoUploads() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: VideoPickerWidget(label: 'Main Movie Video', onVideoSelected: (file) => setState(() => _videoFile = file))),
            const SizedBox(width: 24),
            Expanded(child: VideoPickerWidget(label: 'Trailer Video', onVideoSelected: (file) => setState(() => _trailerFile = file))),
          ],
        ),
        const SizedBox(height: 24),
        FilePickerWidget(label: 'Subtitles', onFilesSelected: (files) => setState(() => _subtitleFiles = files.map((f) => f.bytes!).toList())),
      ],
    );
  }

  Widget _buildTaxonomy() {
    final catProvider = context.watch<CategoryProvider>();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: catProvider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _ageRating,
                decoration: const InputDecoration(labelText: 'Age Rating', border: OutlineInputBorder()),
                items: ['U', 'U/A 7+', 'U/A 13+', 'U/A 16+', 'A'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => _ageRating = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _buildTextField('Release Date', _releaseDateController)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Duration (min)', _durationController, isNumeric: true)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('IMDb Rating', _imdbController, isNumeric: true)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Country', _countryController)),
          ],
        ),
      ],
    );
  }

  Widget _buildCastCrewSection() {
    return Column(
      children: [
        _buildDynamicList('Cast', _cast, ['name', 'role'], (newList) => setState(() => _cast = newList)),
        const SizedBox(height: 32),
        _buildDynamicList('Crew', _crew, ['name', 'role'], (newList) => setState(() => _crew = newList)),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: _buildTextField('Director', _directorController)),
            const SizedBox(width: 24),
            Expanded(child: _buildTextField('Producer', _producerController)),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicList(String title, List<Map<String, String>> list, List<String> fields, Function(List<Map<String, String>>) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            TextButton.icon(onPressed: () => onChanged([...list, {for (var f in fields) f: ''}]), icon: const Icon(Icons.add), label: Text('Add $title')),
          ],
        ),
        ...list.asMap().entries.map((entry) {
          int idx = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                ...fields.map((f) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextFormField(
                      initialValue: entry.value[f],
                      decoration: InputDecoration(labelText: f.toUpperCase(), border: const OutlineInputBorder()),
                      onChanged: (v) => list[idx][f] = v,
                    ),
                  ),
                )),
                IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent), onPressed: () => onChanged([...list]..removeAt(idx))),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPublishingOptions() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<AdminMovieStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: AdminMovieStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
        ),
        const SizedBox(width: 48),
        _buildToggle('Featured', _isFeatured, (v) => setState(() => _isFeatured = v)),
        const SizedBox(width: 24),
        _buildToggle('Trending', _isTrending, (v) => setState(() => _isTrending = v)),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(backgroundColor: AdminColors.primary, foregroundColor: Colors.white),
        child: const Text('SAVE & BEGIN UPLOAD PROCESS', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AdminColors.primary)),
        const Divider(color: Colors.white10),
      ]),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, bool isNumeric = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Switch.adaptive(value: value, activeColor: AdminColors.primary, onChanged: onChanged),
      const SizedBox(width: 8),
      Text(label),
    ]);
  }
}
