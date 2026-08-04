import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/admin_banner_entity.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../../core/theme/admin_dimensions.dart';

/// A preview widget that replicates how the banner will appear 
/// in the consumer app's Hero Carousel.
class BannerSliderPreview extends StatelessWidget {
  final AdminBannerEntity banner;

  const BannerSliderPreview({super.key, required this.banner});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdminDimensions.radiusLarge),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AdminDimensions.radiusLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image based on simulated viewport
              banner.desktopImageUrl.isNotEmpty 
                ? CachedNetworkImage(
                    imageUrl: banner.desktopImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.black12),
                  )
                : Container(color: Colors.black87),

              // Cinematic Gradient
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.4, 0.7, 1.0],
                    colors: [
                      Colors.black38,
                      Colors.transparent,
                      Colors.black54,
                      AdminColors.backgroundDark,
                    ],
                  ),
                ),
              ),

              // Content Overlay
              Padding(
                padding: const EdgeInsets.all(AdminDimensions.paddingExtraLarge),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      banner.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (banner.description != null)
                      Text(
                        banner.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: null, // Disabled in preview
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('WATCH NOW'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.primary,
                            disabledBackgroundColor: AdminColors.primary,
                            disabledForegroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.info_outline),
                          label: const Text('INFO'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Metadata Badges
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    banner.type.name.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
