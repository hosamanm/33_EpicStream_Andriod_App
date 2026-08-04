import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback onEdit;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memberSince = DateFormat('MMMM yyyy').format(profile.createdAt);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppDimensions.l, AppDimensions.xl, AppDimensions.l, AppDimensions.l),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusXL)),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white10,
                backgroundImage: profile.photoUrl != null 
                  ? CachedNetworkImageProvider(profile.photoUrl!) 
                  : null,
                child: profile.photoUrl == null 
                  ? const Icon(Icons.person, size: 55, color: Colors.white24) 
                  : null,
              ),
              GestureDetector(
                onTap: onEdit,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryRed,
                  child: Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.m),
          Text(
            profile.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppDimensions.s),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
            ),
            child: Text(
              'MEMBER SINCE $memberSince',
              style: const TextStyle(
                color: AppColors.primaryRed,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
          if (profile.country != null) ...[
            const SizedBox(height: AppDimensions.s),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  profile.country!,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
