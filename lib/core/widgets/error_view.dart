import 'package:flutter/material.dart';
import '../theme/app_dimensions.dart';

enum ErrorViewType { general, network, empty, maintenance, update }

/// A versatile Error View that handles different failure states across the OTT app.
class AppErrorView extends StatelessWidget {
  final ErrorViewType type;
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppErrorView({
    super.key,
    this.type = ErrorViewType.general,
    this.title,
    this.message,
    this.onRetry,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.l),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(theme),
            const SizedBox(height: AppDimensions.l),
            Text(
              title ?? _getDefaultTitle(),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.s),
            Text(
              message ?? _getDefaultMessage(),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            if (onAction != null)
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Action'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData iconData;
    Color color = theme.colorScheme.primary;

    switch (type) {
      case ErrorViewType.network:
        iconData = Icons.wifi_off_rounded;
        break;
      case ErrorViewType.empty:
        iconData = Icons.movie_filter_outlined;
        break;
      case ErrorViewType.maintenance:
        iconData = Icons.build_circle_outlined;
        break;
      case ErrorViewType.update:
        iconData = Icons.system_update_rounded;
        break;
      case ErrorViewType.general:
      default:
        iconData = Icons.error_outline_rounded;
        color = theme.colorScheme.error;
    }

    return Icon(iconData, size: 80, color: color);
  }

  String _getDefaultTitle() {
    switch (type) {
      case ErrorViewType.network: return 'Connection Lost';
      case ErrorViewType.empty: return 'Nothing Found';
      case ErrorViewType.maintenance: return 'Maintenance in Progress';
      case ErrorViewType.update: return 'Update Available';
      case ErrorViewType.general:
      default: return 'Oops! Something went wrong';
    }
  }

  String _getDefaultMessage() {
    switch (type) {
      case ErrorViewType.network: return 'Please check your internet connection and try again.';
      case ErrorViewType.empty: return 'We couldn\'t find what you were looking for.';
      case ErrorViewType.maintenance: return 'We are currently upgrading our servers. Please check back later.';
      case ErrorViewType.update: return 'A new version of OTT Stream is available with latest features.';
      case ErrorViewType.general:
      default: return 'An unexpected error occurred. Our team has been notified.';
    }
  }
}
