import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';

/// A modern, Material 3 bottom navigation bar for the OTT platform.
/// Features animated icons and badge support.
class OttBottomNavigation extends StatelessWidget {
  const OttBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return NavigationBar(
      selectedIndex: dashboardProvider.currentIndex,
      onDestinationSelected: (index) => dashboardProvider.setIndex(index),
      elevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      indicatorColor: AppColors.primaryRed.withValues(alpha: 0.1),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home, color: AppColors.primaryRed),
          label: l10n.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search, color: AppColors.primaryRed),
          label: l10n.search,
        ),
        NavigationDestination(
          icon: const Icon(Icons.category_outlined),
          selectedIcon: const Icon(Icons.category, color: AppColors.primaryRed),
          label: l10n.categories,
        ),
        NavigationDestination(
          icon: Badge(
            label: dashboardProvider.downloadBadgeCount > 0 
                ? Text(dashboardProvider.downloadBadgeCount.toString()) 
                : null,
            isLabelVisible: dashboardProvider.downloadBadgeCount > 0,
            child: const Icon(Icons.download_for_offline_outlined),
          ),
          selectedIcon: const Icon(Icons.download_for_offline, color: AppColors.primaryRed),
          label: 'Downloads',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person, color: AppColors.primaryRed),
          label: l10n.profile,
        ),
      ],
    );
  }
}
