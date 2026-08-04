import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/auth_notifier.dart';
import '../providers/auth_state.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final List<String> _genres = [
    'Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi', 
    'Romance', 'Thriller', 'Documentary', 'Animation'
  ];
  final List<String> _selectedGenres = [];
  String? _selectedCountry;

  void _handleComplete() async {
    final authNotifier = context.read<AuthNotifier>();
    final authState = authNotifier.state;

    if (authState is Authenticated) {
      final updatedProfile = authState.userProfile.copyWith(
        favoriteGenres: _selectedGenres,
        country: _selectedCountry,
        updatedAt: DateTime.now(),
      );
      
      await context.read<ProfileProvider>().updateProfile(updatedProfile);
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('SKIP', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personalize Your Experience',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.s),
            const Text(
              'Select your favorite genres and country to help us recommend better content for you.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: AppDimensions.xl),
            
            Text('Favorite Genres', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.m),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _genres.map((genre) {
                final isSelected = _selectedGenres.contains(genre);
                return FilterChip(
                  label: Text(genre),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedGenres.add(genre);
                      } else {
                        _selectedGenres.remove(genre);
                      }
                    });
                  },
                  selectedColor: AppColors.primaryRed.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryRed,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryRed : Colors.white70,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppDimensions.xl),
            Text('Country', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppDimensions.m),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text('Select your country', style: TextStyle(color: Colors.white38)),
              items: ['USA', 'UK', 'India', 'Canada', 'Australia']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCountry = val),
            ),
            
            const SizedBox(height: AppDimensions.xxl),
            ElevatedButton(
              onPressed: _handleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('FINISH', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
