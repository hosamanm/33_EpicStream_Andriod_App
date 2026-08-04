import 'package:flutter/material.dart';
import '../../../../core/theme/app_dimensions.dart';

/// A widget to display when a section has no content.
class EmptySection extends StatelessWidget {
  final String title;
  final String message;

  const EmptySection({
    super.key,
    required this.title,
    this.message = 'No content available at the moment.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.m, vertical: AppDimensions.s),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 100,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: AppDimensions.m),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Center(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.l),
      ],
    );
  }
}
