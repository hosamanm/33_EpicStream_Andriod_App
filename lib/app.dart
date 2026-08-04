import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:epic_stream/l10n/app_localizations.dart';
import 'package:epic_stream/core/theme/app_theme.dart';
import 'package:epic_stream/core/routes/app_router.dart';
import 'package:epic_stream/core/di/injection.dart';
import 'package:epic_stream/core/services/navigation_service.dart';
import 'package:epic_stream/core/services/connectivity_service.dart';
import 'package:epic_stream/core/widgets/connectivity_banner.dart';
import 'package:epic_stream/features/auth/presentation/providers/auth_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/onboarding_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/splash_notifier.dart';
import 'package:epic_stream/features/auth/presentation/providers/phone_auth_notifier.dart';
import 'package:epic_stream/features/home/presentation/providers/dashboard_provider.dart';
import 'package:epic_stream/features/home/presentation/providers/home_provider.dart';
import 'package:epic_stream/features/home/presentation/providers/banner_provider.dart';
import 'package:epic_stream/features/player/presentation/providers/video_player_provider.dart';
import 'package:epic_stream/features/profile/presentation/providers/profile_provider.dart';
import 'package:epic_stream/features/profile/data/services/profile_service.dart';
import 'package:epic_stream/features/watchlist/presentation/providers/watchlist_provider.dart';
import 'package:epic_stream/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:epic_stream/features/favorites/data/services/favorite_service.dart';
import 'package:epic_stream/features/history/presentation/providers/continue_watching_provider.dart';
import 'package:epic_stream/features/history/presentation/providers/history_provider.dart';
import 'package:epic_stream/features/downloads/presentation/providers/download_provider.dart';
import 'package:epic_stream/features/search/presentation/providers/search_provider.dart';
import 'package:epic_stream/features/search/presentation/providers/recent_search_provider.dart';
import 'package:epic_stream/features/search/data/services/search_service.dart';
import 'package:epic_stream/features/categories/presentation/providers/categories_provider.dart';
import 'package:epic_stream/features/notifications/presentation/providers/notification_provider.dart';

class OttApp extends StatelessWidget {
  const OttApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services & Singletons
        Provider.value(value: sl<ConnectivityService>()),
        Provider.value(value: sl<ProfileService>()),
        Provider.value(value: sl<FavoriteService>()),
        Provider.value(value: sl<SearchService>()),
        
        // State Notifiers - Global singletons provided via .value to ensure persistence
        ChangeNotifierProvider.value(value: sl<AuthNotifier>()),
        ChangeNotifierProvider.value(value: sl<OnboardingNotifier>()),
        ChangeNotifierProvider.value(value: sl<SplashNotifier>()),
        ChangeNotifierProvider.value(value: sl<DashboardProvider>()),
        
        // Feature States
        ChangeNotifierProvider(create: (_) => sl<PhoneAuthNotifier>()),
        ChangeNotifierProvider(create: (_) => sl<HomeProvider>()),
        ChangeNotifierProvider(create: (_) => sl<BannerProvider>()..init()),
        ChangeNotifierProvider(create: (_) => sl<VideoPlayerProvider>()),
        ChangeNotifierProvider.value(value: sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<WatchlistProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FavoriteProvider>()..init()),
        ChangeNotifierProvider(create: (_) => sl<ContinueWatchingProvider>()),
        ChangeNotifierProvider(create: (_) => sl<HistoryProvider>()),
        ChangeNotifierProvider.value(value: sl<DownloadProvider>()),
        
        // Search & Discovery
        ChangeNotifierProvider.value(value: sl<SearchProvider>()),
        ChangeNotifierProvider.value(value: sl<RecentSearchProvider>()),
        ChangeNotifierProvider.value(value: sl<CategoriesProvider>()),
        ChangeNotifierProvider.value(value: sl<NotificationProvider>()),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final themeMode = _parseThemeMode(profileProvider.profile?.themeMode);
          final locale = _parseLocale(profileProvider.profile?.language);
          
          return MaterialApp.router(
            title: 'EpicStream',
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            scaffoldMessengerKey: sl<NavigationService>().messengerKey,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              if (child == null) return const SizedBox.shrink();
              
              return Material(
                color: Colors.black,
                child: StreamBuilder<ConnectivityStatus>(
                  stream: sl<ConnectivityService>().connectivityStream,
                  builder: (context, snapshot) {
                    final isOffline = snapshot.data == ConnectivityStatus.offline;
                    return Stack(
                      children: [
                        Positioned.fill(child: child),
                        if (isOffline)
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ConnectivityBanner(),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  ThemeMode _parseThemeMode(String? mode) {
    switch (mode) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  Locale _parseLocale(String? lang) {
    if (lang == null || lang.isEmpty) return const Locale('en', '');
    return Locale(lang, '');
  }
}
