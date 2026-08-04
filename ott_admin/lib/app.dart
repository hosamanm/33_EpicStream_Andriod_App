import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'core/theme/admin_theme.dart';
import 'core/routes/admin_router.dart';

/// The root widget of the OTT Admin Panel application.
/// Optimized for Web with responsive breakpoints and persistent routing.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OTT Admin Panel',
      debugShowCheckedModeBanner: false,

      // --- Navigation Configuration ---
      routerConfig: AdminRouter.router,

      // --- Theme Configuration ---
      theme: AdminTheme.lightTheme,
      darkTheme: AdminTheme.darkTheme,
      themeMode: ThemeMode.system,

      // --- Responsive Framework Integration ---
      // Ensures the dashboard scales gracefully from Mobile to 4K Monitors.
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),
    );
  }
}
