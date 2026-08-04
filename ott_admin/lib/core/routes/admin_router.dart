import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../di/injection.dart';
import '../../features/auth/presentation/providers/admin_auth_provider.dart';
import '../../features/auth/domain/entities/admin_entity.dart';
import '../../features/auth/presentation/pages/admin_login_screen.dart';
import '../../features/auth/presentation/pages/unauthorized_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/movies/presentation/pages/movies_screen.dart';
import '../../features/movies/presentation/pages/trailers_screen.dart';
import '../../features/users/presentation/pages/users_screen.dart';
import '../../features/categories/presentation/pages/categories_screen.dart';
import '../../features/categories/presentation/pages/genre_screen.dart';
import '../../features/categories/presentation/pages/language_screen.dart';
import '../../features/categories/presentation/pages/country_screen.dart';
import '../../features/categories/presentation/pages/age_rating_screen.dart';
import '../../features/categories/presentation/pages/home_sections_screen.dart';
import '../../features/banners/presentation/pages/banner_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/settings/presentation/pages/admin_settings_screen.dart';
import '../theme/admin_colors.dart';
import 'admin_guard.dart';

class AdminRouter {
  AdminRouter._();

  static const String login = '/login';
  static const String unauthorized = '/unauthorized';
  static const String dashboard = '/';
  static const String movies = '/movies';
  static const String trailers = '/trailers';
  static const String categories = '/categories';
  static const String genres = '/genres';
  static const String languages = '/languages';
  static const String countries = '/countries';
  static const String ageRatings = '/age-ratings';
  static const String homeSections = '/home-sections';
  static const String users = '/users';
  static const String banners = '/banners';
  static const String notifications = '/notifications';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    refreshListenable: sl<AdminAuthProvider>(),
    redirect: (context, state) => AdminGuard(sl<AdminAuthProvider>()).redirect(context, state),

    routes: [
      GoRoute(path: login, builder: (context, state) => const AdminLoginScreen()),
      GoRoute(path: unauthorized, builder: (context, state) => const UnauthorizedScreen()),
      
      ShellRoute(
        builder: (context, state, child) => _AdminScaffold(child: child),
        routes: [
          GoRoute(path: dashboard, builder: (context, state) => const DashboardScreen()),
          GoRoute(path: movies, builder: (context, state) => const MoviesScreen()),
          GoRoute(path: trailers, builder: (context, state) => const TrailersScreen()),
          GoRoute(path: categories, builder: (context, state) => const CategoriesScreen()),
          GoRoute(path: genres, builder: (context, state) => const GenreScreen()),
          GoRoute(path: languages, builder: (context, state) => const LanguageScreen()),
          GoRoute(path: countries, builder: (context, state) => const CountryScreen()),
          GoRoute(path: ageRatings, builder: (context, state) => const AgeRatingScreen()),
          GoRoute(path: homeSections, builder: (context, state) => const HomeSectionsScreen()),
          GoRoute(path: users, builder: (context, state) => const UsersScreen()),
          GoRoute(path: banners, builder: (context, state) => const BannerScreen()),
          GoRoute(path: notifications, builder: (context, state) => const NotificationsScreen()),
          GoRoute(path: reports, builder: (context, state) => const AnalyticsScreen()),
          GoRoute(path: settings, builder: (context, state) => const AdminSettingsScreen()),
          GoRoute(path: profile, builder: (context, state) => const _Placeholder(title: 'Admin Profile Settings')),
        ],
      ),
    ],
  );
}

class _AdminScaffold extends StatefulWidget {
  final Widget child;
  const _AdminScaffold({required this.child});

  @override
  State<_AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<_AdminScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AdminAuthProvider>().state;
    final admin = authState.admin;
    final currentPath = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarCollapsed ? 80 : 260,
            color: AdminColors.surfaceDark,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Icon(Icons.play_circle_fill, size: 40, color: AdminColors.primary),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(height: 12),
                  const Text('EPICSTREAM', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
                  const Text('ADMIN PANEL', style: TextStyle(fontSize: 10, color: Colors.white38, letterSpacing: 1.5)),
                ],
                const SizedBox(height: 32),
                Expanded(
                  child: ListView(
                    children: [
                      _SidebarItem(icon: Icons.dashboard_outlined, label: 'Dashboard', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.dashboard, onTap: () => context.go(AdminRouter.dashboard)),
                      
                      if (admin?.canManageContent ?? false) ...[
                        _buildDivider(),
                        _SidebarItem(icon: Icons.movie_outlined, label: 'Movies', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.movies, onTap: () => context.go(AdminRouter.movies)),
                        _SidebarItem(icon: Icons.movie_filter_outlined, label: 'Trailers', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.trailers, onTap: () => context.go(AdminRouter.trailers)),
                        _SidebarItem(icon: Icons.category_outlined, label: 'Categories', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.categories, onTap: () => context.go(AdminRouter.categories)),
                        _SidebarItem(icon: Icons.style_outlined, label: 'Genres', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.genres, onTap: () => context.go(AdminRouter.genres)),
                        _SidebarItem(icon: Icons.translate_outlined, label: 'Languages', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.languages, onTap: () => context.go(AdminRouter.languages)),
                        _SidebarItem(icon: Icons.public_outlined, label: 'Countries', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.countries, onTap: () => context.go(AdminRouter.countries)),
                        _SidebarItem(icon: Icons.explicit_outlined, label: 'Age Ratings', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.ageRatings, onTap: () => context.go(AdminRouter.ageRatings)),
                        _SidebarItem(icon: Icons.view_quilt_outlined, label: 'Home Sections', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.homeSections, onTap: () => context.go(AdminRouter.homeSections)),
                      ],

                      if (admin?.canManageUsers ?? false) ...[
                        _buildDivider(),
                        _SidebarItem(icon: Icons.people_outline, label: 'Users', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.users, onTap: () => context.go(AdminRouter.users)),
                        _SidebarItem(icon: Icons.view_carousel_outlined, label: 'Banners', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.banners, onTap: () => context.go(AdminRouter.banners)),
                        _SidebarItem(icon: Icons.notifications_none_outlined, label: 'Notifications', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.notifications, onTap: () => context.go(AdminRouter.notifications)),
                      ],

                      _buildDivider(),
                      _SidebarItem(icon: Icons.analytics_outlined, label: 'Reports', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.reports, onTap: () => context.go(AdminRouter.reports)),
                      
                      if (admin?.isSuperAdmin ?? false)
                        _SidebarItem(icon: Icons.settings_outlined, label: 'Settings', isCollapsed: _isSidebarCollapsed, isSelected: currentPath == AdminRouter.settings, onTap: () => context.go(AdminRouter.settings)),
                    ],
                  ),
                ),
                _SidebarItem(
                  icon: Icons.logout_rounded, 
                  label: 'Logout', 
                  isCollapsed: _isSidebarCollapsed, 
                  isSelected: false,
                  onTap: () => context.read<AdminAuthProvider>().logout(),
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: Icon(_isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left),
                  onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    border: const Border(bottom: BorderSide(color: Colors.white10)),
                  ),
                  child: Row(
                    children: [
                      Text(_getPageTitle(currentPath), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.search, color: Colors.white38),
                      const SizedBox(width: 24),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                      const VerticalDivider(indent: 16, endIndent: 16, width: 32),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(admin?.fullName ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(admin?.role.name.toUpperCase() ?? 'SUPER ADMIN', style: TextStyle(fontSize: 10, color: AdminColors.primary)),
                        ],
                      ),
                      const SizedBox(width: 12),
                      const CircleAvatar(radius: 18, child: Icon(Icons.person)),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Padding(
    padding: EdgeInsets.symmetric(horizontal: _isSidebarCollapsed ? 16 : 24, vertical: 8),
    child: const Divider(color: Colors.white10, height: 1),
  );

  String _getPageTitle(String path) {
    if (path == AdminRouter.dashboard) return 'Dashboard Overview';
    if (path == AdminRouter.movies) return 'Movie Library';
    if (path == AdminRouter.trailers) return 'Trailer Management';
    if (path == AdminRouter.categories) return 'Categories';
    if (path == AdminRouter.genres) return 'Genre Metadata';
    if (path == AdminRouter.languages) return 'Supported Languages';
    if (path == AdminRouter.countries) return 'Supported Countries';
    if (path == AdminRouter.ageRatings) return 'Age Ratings';
    if (path == AdminRouter.homeSections) return 'Home Content Layout';
    if (path == AdminRouter.users) return 'User Management';
    if (path == AdminRouter.banners) return 'Promotional Banners';
    if (path == AdminRouter.notifications) return 'Notification Composer';
    if (path == AdminRouter.reports) return 'Platform Analytics';
    if (path == AdminRouter.settings) return 'Global App Settings';
    return '';
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isCollapsed;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _SidebarItem({
    required this.icon, 
    required this.label, 
    required this.isCollapsed, 
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: isSelected,
      leading: Icon(icon, color: isSelected ? AdminColors.primary : (color ?? Colors.white70)),
      title: isCollapsed ? null : Text(
        label, 
        style: TextStyle(
          color: isSelected ? Colors.white : (color ?? Colors.white70),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 28 : 24),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});
  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title, style: const TextStyle(fontSize: 24, color: Colors.white38)));
  }
}
