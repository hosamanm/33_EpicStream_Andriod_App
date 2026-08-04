import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../features/auth/data/services/admin_service.dart';
import '../../features/auth/data/repositories/admin_repository_impl.dart';
import '../../features/auth/domain/repositories/admin_repository.dart';
import '../../features/auth/presentation/providers/admin_auth_provider.dart';
import '../../features/auth/presentation/controllers/admin_auth_controller.dart';
import '../../features/dashboard/data/services/dashboard_service.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/analytics/data/services/analytics_service.dart';
import '../../features/analytics/data/services/report_generator.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/providers/analytics_provider.dart';
import '../../features/notifications/data/services/admin_notification_service.dart';
import '../../features/movies/data/services/admin_movie_service.dart';
import '../../features/movies/data/services/firebase_storage_service.dart';
import '../../features/movies/data/services/cloudflare_tus_service.dart';
import '../../features/movies/data/services/upload_service.dart';
import '../../features/movies/data/repositories/admin_movie_repository_impl.dart';
import '../../features/movies/domain/repositories/admin_movie_repository.dart';
import '../../features/movies/presentation/providers/movie_provider.dart';
import '../../features/movies/presentation/providers/movie_upload_provider.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/presentation/providers/category_provider.dart';
import '../../features/users/data/services/admin_user_service.dart';
import '../../features/users/data/repositories/admin_user_repository_impl.dart';
import '../../features/users/domain/repositories/admin_user_repository.dart';
import '../../features/users/presentation/providers/admin_user_provider.dart';
import '../../features/banners/data/repositories/admin_banner_repository_impl.dart';
import '../../features/banners/domain/repositories/banner_repository.dart';
import '../../features/banners/data/services/admin_banner_service.dart';
import '../../features/activity_logs/data/services/activity_log_service.dart';
import '../../features/activity_logs/data/repositories/activity_log_repository_impl.dart';
import '../../features/activity_logs/domain/repositories/activity_log_repository.dart';
import '../../features/activity_logs/presentation/providers/activity_log_provider.dart';
import '../services/session_manager.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Core ---
  sl.registerLazySingleton(() => Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      // Removed fixed timestamp format to avoid version compatibility issues
    ),
  ));
  sl.registerLazySingleton(() => Dio());

  // --- Firebase ---
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseFunctions.instance);

  // --- Services ---
  sl.registerLazySingleton(() => SessionManager(sl()));
  sl.registerLazySingleton(() => FirebaseStorageService(sl(), sl()));
  sl.registerLazySingleton(() => CloudflareTusService(sl(), sl()));
  sl.registerLazySingleton(() => AdminMovieService(sl(), sl(), sl()));
  sl.registerLazySingleton(() => UploadService(sl(), sl(), sl(), sl()));

  // --- Activity Logs Feature ---
  sl.registerLazySingleton(() => ActivityLogService(sl()));
  sl.registerLazySingleton<ActivityLogRepository>(() => ActivityLogRepositoryImpl(sl()));
  sl.registerFactory(() => ActivityLogProvider(sl()));

  // --- Auth Feature ---
  sl.registerLazySingleton(() => AdminService(sl(), sl()));
  sl.registerLazySingleton<AdminRepository>(() => AdminRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => AdminAuthProvider(sl()));
  sl.registerLazySingleton(() => AdminAuthController(sl()));

  // --- Dashboard Feature ---
  sl.registerLazySingleton(() => DashboardService(sl()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(sl()));
  sl.registerFactory(() => DashboardProvider(sl()));

  // --- Analytics Feature ---
  sl.registerLazySingleton(() => AnalyticsService(sl()));
  sl.registerLazySingleton(() => ReportGenerator());
  sl.registerLazySingleton<AnalyticsRepository>(() => AnalyticsRepositoryImpl(sl()));
  sl.registerFactory(() => AnalyticsProvider(sl()));

  // --- Movies Feature ---
  sl.registerLazySingleton<AdminMovieRepository>(() => AdminMovieRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => AdminMovieProvider(sl()));
  sl.registerLazySingleton(() => MovieUploadProvider(sl()));

  // --- Categories Feature ---
  sl.registerLazySingleton<CategoryRepository>(() => CategoryRepositoryImpl(sl(), sl(), sl(), sl())); 
  sl.registerLazySingleton(() => CategoryProvider(sl()));

  // --- Users Feature ---
  sl.registerLazySingleton(() => AdminUserService(sl()));
  sl.registerLazySingleton<AdminUserRepository>(() => AdminUserRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton(() => AdminUserProvider(sl()));

  // --- Banners Feature ---
  sl.registerLazySingleton(() => AdminBannerService(sl()));
  sl.registerLazySingleton<BannerRepository>(() => AdminBannerRepositoryImpl(sl(), sl(), sl()));

  // --- Notifications Feature ---
  sl.registerLazySingleton(() => AdminNotificationService(sl(), sl(), sl(), sl()));
}
