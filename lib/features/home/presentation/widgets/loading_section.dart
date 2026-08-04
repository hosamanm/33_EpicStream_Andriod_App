import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_dimensions.dart';

/// A shimmering loading placeholder for a movie section.
/// Matches the layout of the actual section to provide a smooth transition.
class LoadingSection extends StatelessWidget {
  final bool isLandscape;

  const LoadingSection({
    super.key,
    this.isLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Shimmer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
          child: Shimmer.fromColors(
            baseColor: Colors.white10,
            highlightColor: Colors.white24,
            child: Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        
        // List Shimmer
        SizedBox(
          height: isLandscape ? 160 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
            itemCount: 5,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.m),
                child: Shimmer.fromColors(
                  baseColor: Colors.white10,
                  highlightColor: Colors.white24,
                  child: Container(
                    width: isLandscape ? 240 : 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppDimensions.l),
      ],
    );
  }
}
