import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/genre_entity.dart';

/// A reusable chip for displaying and selecting genres.
class GenreChip extends StatelessWidget {
  final GenreEntity genre;
  final bool isSelected;
  final VoidCallback onTap;

  const GenreChip({
    super.key,
    required this.genre,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.m,
          vertical: AppDimensions.s,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryRed : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
          border: Border.all(
            color: isSelected ? AppColors.primaryRed : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          genre.name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
