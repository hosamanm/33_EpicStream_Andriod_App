import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/services/profile_service.dart';
import '../providers/profile_provider.dart';
import '../controllers/profile_controller.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late ProfileController _controller;
  
  List<String> _selectedGenres = [];
  File? _imageFile;
  bool _isUploading = false;

  final List<String> _availableGenres = [
    'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 'Thriller', 'Romance', 'Documentary', 'Anime'
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile?.displayName);
    _phoneController = TextEditingController(text: profile?.phoneNumber);
    _countryController = TextEditingController(text: profile?.country);
    _selectedGenres = List.from(profile?.favoriteGenres ?? []);
    
    _controller = ProfileController(
      context.read<ProfileService>(), 
      context.read<ProfileProvider>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
  }

  Future<void> _saveProfile() async {
    setState(() => _isUploading = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await context.read<ProfileService>().uploadProfilePicture(_imageFile!);
      }

      await _controller.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        favoriteGenres: _selectedGenres,
        profileImage: imageUrl,
      );
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isUploading)
            const Center(child: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(onPressed: _saveProfile, child: const Text('SAVE', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.darkSurface,
                    backgroundImage: _imageFile != null ? FileImage(_imageFile!) : (profile?.photoUrl != null ? NetworkImage(profile!.photoUrl!) as ImageProvider : null),
                    child: _imageFile == null && profile?.photoUrl == null ? const Icon(Icons.person, size: 60, color: Colors.white24) : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryRed,
                    child: IconButton(icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white), onPressed: _pickImage),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            AppTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person_outline),
            const SizedBox(height: AppDimensions.m),
            AppTextField(controller: _phoneController, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: AppDimensions.m),
            AppTextField(controller: _countryController, label: 'Country', prefixIcon: Icons.public),
            const SizedBox(height: AppDimensions.l),
            const Text('Favorite Genres', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: AppDimensions.s),
            Wrap(
              spacing: 8,
              children: _availableGenres.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selected ? _selectedGenres.add(genre) : _selectedGenres.remove(genre);
                    });
                  },
                  selectedColor: AppColors.primaryRed.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryRed,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
