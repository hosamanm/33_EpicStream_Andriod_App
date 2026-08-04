import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/signup_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/splash_notifier.dart';
import '../../features/auth/presentation/providers/onboarding_notifier.dart';
import '../../features/auth/presentation/providers/phone_auth_notifier.dart';

import '../../features/profile/data/datasources/user_profile_remote_datasource.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/profile/domain/usecases/create_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/delete_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/data/services/profile_service.dart';
import '../../features/profile/data/services/feedback_service.dart';

import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/presentation/providers/dashboard_provider.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/home/presentation/providers/banner_provider.dart';

import '../../features/movies/data/datasources/movie_remote_datasource.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/presentation/providers/movie_details_provider.dart';

import '../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/presentation/providers/categories_provider.dart';

import '../../features/search/data/services/search_service.dart';
import '../../features/search/presentation/providers/search_provider.dart';
import '../../features/search/presentation/providers/recent_search_provider.dart';
import '../../features/search/presentation/controllers/search_controller.dart';

import '../../features/watchlist/data/datasources/watchlist_remote_datasource.dart';
import '../../features/watchlist/data/repositories/watchlist_repository_impl.dart';
import '../../features/watchlist/domain/repositories/watchlist_repository.dart';
import '../../features/watchlist/presentation/controllers/watchlist_controller.dart';
import '../../features/watchlist/presentation/providers/watchlist_provider.dart';

import '../../features/favorites/data/datasources/favorite_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/presentation/providers/favorite_provider.dart';
import '../../features/favorites/data/services/favorite_service.dart';

import '../../features/history/data/datasources/playback_progress_remote_datasource.dart';
import '../../features/history/data/repositories/player_progress_repository_impl.dart';
import '../../features/history/domain/repositories/player_progress_repository.dart';
import '../../features/history/data/services/continue_watching_service.dart';
import '../../features/history/data/services/watch_history_service.dart';
import '../../features/history/presentation/providers/continue_watching_provider.dart';
import '../../features/history/presentation/providers/history_provider.dart';

import '../../features/player/data/services/player_service.dart';
import '../../features/player/data/repositories/player_repository_impl.dart';
import '../../features/player/domain/repositories/player_repository.dart';
import '../../features/player/presentation/providers/video_player_provider.dart';

import '../../features/notifications/data/datasources/notification_remote_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';

import '../../features/downloads/data/datasources/download_local_datasource.dart';
import '../../features/downloads/data/repositories/download_repository_impl.dart';
import '../../features/downloads/domain/repositories/download_repository.dart';
import '../../features/downloads/data/services/download_service.dart';
import '../../features/downloads/presentation/providers/download_provider.dart';

import '../services/firebase_service.dart';
import '../services/connectivity_service.dart';
import '../services/navigation_service.dart';
import '../services/secure_storage_service.dart';
import '../services/device_service.dart';
import '../services/storage_service.dart';
import '../services/analytics_service.dart';
import '../services/cache_service.dart';
import '../services/security_service.dart';
import '../network/retry_policy.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- External ---
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPrefs);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // --- Firebase ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseAnalytics.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);

  // --- Core ---
  sl.registerLazySingleton(() => Logger());
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => RetryPolicy(sl()));

  // --- Services ---
  sl.registerLazySingleton(() => NavigationService());
  sl.registerLazySingleton(() => ConnectivityService(sl()));
  sl.registerLazySingleton(() => FirebaseService(sl()));
  sl.registerLazySingleton(() => SecureStorageService(sl()));
  sl.registerLazySingleton(() => DeviceService());
  sl.registerLazySingleton(() => StorageService(sl()));
  sl.registerLazySingleton(() => AppAnalyticsService(sl(), sl()));
  sl.registerLazySingleton(() => CacheService(sl()));
  sl.registerLazySingleton(() => SecurityService(sl()));

  // --- Auth Notifiers ---
  sl.registerLazySingleton<AuthNotifier>(
    () => AuthNotifier(
      loginUseCase: sl(),
      signUpUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      getUserProfileUseCase: sl(),
      createUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      forgotPasswordUseCase: sl(),
      authRepository: sl(),
      secureStorage: sl(),
      deviceService: sl(),
    ),
  );

  sl.registerLazySingleton<SplashNotifier>(
    () => SplashNotifier(
      authNotifier: sl(),
      connectivityService: sl(),
    ),
  );

  sl.registerLazySingleton<OnboardingNotifier>(
    () => OnboardingNotifier(sl()),
  );

  // --- Features - Auth ---
  sl.registerLazySingleton<AuthRemoteDataSource>(() => FirebaseAuthDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl()));
  sl.registerFactory(() => PhoneAuthNotifier(sl()));

  // --- Features - Profile ---
  sl.registerLazySingleton<UserProfileRemoteDataSource>(() => UserProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<UserProfileRepository>(() => UserProfileRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => ProfileService(sl(), sl(), sl()));
  sl.registerLazySingleton(() => FeedbackService(sl(), sl()));
  sl.registerLazySingleton(() => ProfileProvider(sl()));

  // --- Features - Movies & Dashboard ---
  sl.registerLazySingleton<MovieRemoteDataSource>(() => MovieRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      sl(),
      cacheService: sl(),
      retryPolicy: sl(),
      logger: sl(),
    ),
  );
  sl.registerFactory(() => MovieDetailsProvider());
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerFactory(() => DashboardProvider());
  sl.registerFactory(() => HomeProvider());
  sl.registerFactory(() => BannerProvider());

  // --- Features - Categories ---
  sl.registerLazySingleton<CategoryRemoteDataSource>(() => CategoryRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CategoriesProvider(sl()));

  // --- Features - History ---
  sl.registerLazySingleton<PlaybackProgressRemoteDataSource>(() => PlaybackProgressRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<PlayerProgressRepository>(
    () => PlayerProgressRepositoryImpl(
      sl<PlaybackProgressRemoteDataSource>(), 
      sl<FirebaseAuth>(), 
    ),
  );
  sl.registerLazySingleton(() => ContinueWatchingService(sl(), sl()));
  sl.registerLazySingleton(() => WatchHistoryService(sl()));
  sl.registerFactory(() => ContinueWatchingProvider(sl()));
  sl.registerFactory(() => HistoryProvider(sl()));

  // --- Features - Player ---
  sl.registerLazySingleton(() => PlayerService(sl()));
  sl.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(sl<PlayerService>(), sl<FirebaseAuth>()),
  );
  sl.registerFactory(() => VideoPlayerProvider());

  // --- Features - Notifications ---
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl<NotificationRemoteDataSource>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(() => NotificationProvider(sl()));

  // --- Features - Search ---
  sl.registerLazySingleton(() => SearchService(sl()));
  sl.registerLazySingleton(() => SearchProvider());
  sl.registerLazySingleton(() => RecentSearchProvider(sl()));
  sl.registerLazySingleton(
    () => SearchModuleController(
      searchProvider: sl(),
      recentSearchProvider: sl(),
      searchService: sl(),
    ),
  );

  // --- Features - Watchlist ---
  sl.registerLazySingleton<WatchlistRemoteDataSource>(
    () => WatchlistRemoteDataSourceImpl(sl<FirebaseFirestore>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<WatchlistRepository>(() => WatchlistRepositoryImpl(sl(), sl()));
  sl.registerFactory(() => WatchlistProvider(sl()));
  sl.registerLazySingleton(() => WatchlistController(sl(), sl()));

  // --- Features - Favorites ---
  sl.registerLazySingleton<FavoriteRemoteDataSource>(() => FavoriteRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<FavoriteRemoteDataSource>(), sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton(() => FavoriteService(sl()));
  sl.registerLazySingleton(() => FavoriteProvider(sl()));

  // --- Features - Downloads ---
  sl.registerLazySingleton<DownloadLocalDataSource>(() => DownloadLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<DownloadRepository>(() => DownloadRepositoryImpl(sl()));
  sl.registerLazySingleton(() => DownloadService(sl(), sl()));
  sl.registerLazySingleton(() => DownloadProvider(sl(), sl()));
}
