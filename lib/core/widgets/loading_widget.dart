import 'package:flutter/material.dart';

/// A reusable loading widget for the OTT platform.
/// Uses Material 3 styles and brand colors.
class AppLoadingWidget extends StatelessWidget {
  final String? message;
  final bool isOverlay;

  const AppLoadingWidget({
    super.key,
    this.message,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator.adaptive(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isOverlay) {
      return Container(
        color: Colors.black54,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}
