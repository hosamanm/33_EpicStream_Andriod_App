import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../categories/presentation/pages/categories_screen.dart';
import '../../../favorites/presentation/pages/favorites_screen.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../search/presentation/pages/search_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/ott_bottom_navigation.dart';
import 'home_screen.dart';

/// The Main Dashboard of the OTT application.
/// Manages the primary navigation and ensures responsive layouts.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<DashboardProvider>().currentIndex;

    final List<Widget> pages = [
      const HomeScreen(),
      const SearchScreen(),
      const CategoriesScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            // Tablet / Desktop / TV Layout: Side Navigation Rail
            return Row(
              children: [
                _buildNavigationRail(context),
                const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
                Expanded(
                  child: IndexedStack(
                    index: currentIndex,
                    children: pages,
                  ),
                ),
              ],
            );
          } else {
            // Mobile Layout: Bottom Navigation
            return IndexedStack(
              index: currentIndex,
              children: pages,
            );
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width <= 900 
          ? const OttBottomNavigation() 
          : null,
    );
  }

  Widget _buildNavigationRail(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    return NavigationRail(
      selectedIndex: dashboard.currentIndex,
      onDestinationSelected: dashboard.setIndex,
      labelType: NavigationRailLabelType.all,
      backgroundColor: const Color(0xFF121212),
      selectedIconTheme: const IconThemeData(color: Colors.red),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.search),
          selectedIcon: Icon(Icons.search),
          label: Text('Search'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: Text('Categories'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: Text('Favorites'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }
}
