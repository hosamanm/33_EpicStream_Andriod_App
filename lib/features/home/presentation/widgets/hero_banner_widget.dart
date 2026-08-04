import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/banner_item.dart';
import '../providers/banner_provider.dart';

/// A Hero Banner Carousel with cinematic animations and metadata.
/// Supports infinite-like scrolling and auto-sliding functionality.
class HeroBannerWidget extends StatelessWidget {
  const HeroBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerProvider = context.watch<BannerProvider>();
    final banners = bannerProvider.banners;

    if (banners.isEmpty) return const SizedBox.shrink();

    // To simulate infinite scroll, we use a very large itemCount in the PageView
    // and map the index using the modulo operator.
    const int infiniteCount = 10000;

    return Column(
      children: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: Stack(
              children: [
                // 1. Animated PageView for Cinematic Transitions
                PageView.builder(
                  controller: bannerProvider.pageController,
                  itemCount: infiniteCount,
                  onPageChanged: (index) {
                    bannerProvider.onPageChanged(index % banners.length);
                  },
                  itemBuilder: (context, index) {
                    final banner = banners[index % banners.length];
                    return _BannerItemWidget(banner: banner);
                  },
                ),

                // 2. Custom Page Indicator
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      banners.length,
                      (index) => _buildIndicator(
                        index == (bannerProvider.currentIndex % banners.length),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isActive ? 24 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryRed : Colors.white38,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _BannerItemWidget extends StatelessWidget {
  final BannerItem banner;

  const _BannerItemWidget({required this.banner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Hero(
      tag: 'hero_banner_${banner.id}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cinematic Backdrop
          CachedNetworkImage(
            imageUrl: banner.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.black),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),

          // Multi-layer Gradient for Text Legibility
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
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),

          // Movie Information & Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.l, vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Genre Chips
                Wrap(
                  spacing: 8,
                  children: banner.genres.map((genre) => _GenreChip(label: genre)).toList(),
                ),
                const SizedBox(height: AppDimensions.m),

                // Movie Logo or Title
                if (banner.logoUrl != null)
                  CachedNetworkImage(
                    imageUrl: banner.logoUrl!,
                    height: 80,
                    width: 200,
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.contain,
                  )
                else
                  Text(
                    banner.title.toUpperCase(),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                const SizedBox(height: AppDimensions.s),

                // Metadata Row
                Row(
                  children: [
                    _MetaBadge(text: banner.rating, icon: Icons.star, color: Colors.amber),
                    const SizedBox(width: 12),
                    _MetaText(text: banner.year),
                    const SizedBox(width: 12),
                    _MetaText(text: banner.duration),
                    const SizedBox(width: 12),
                    _MetaText(text: banner.language, isBordered: true),
                  ],
                ),
                const SizedBox(height: AppDimensions.m),

                // Description
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: Text(
                    banner.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // Action Buttons
                Row(
                  children: [
                    _PrimaryButton(
                      label: 'WATCH NOW',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppDimensions.m),
                    _SecondaryButton(
                      label: 'MY LIST',
                      icon: Icons.add,
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppDimensions.m),
                    _SecondaryButton(
                      label: 'TRAILER',
                      icon: Icons.movie_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  const _MetaBadge({required this.text, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  final String text;
  final bool isBordered;
  const _MetaText({required this.text, this.isBordered = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: isBordered ? const EdgeInsets.symmetric(horizontal: 4, vertical: 1) : null,
      decoration: isBordered ? BoxDecoration(border: Border.all(color: Colors.white54, width: 0.5)) : null,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _SecondaryButton({required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white54),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
      ),
    );
  }
}
