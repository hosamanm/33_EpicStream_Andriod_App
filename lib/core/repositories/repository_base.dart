import 'package:logger/logger.dart';
import '../error/error_mapper.dart';
import '../error/failures.dart';
import '../network/retry_policy.dart';
import '../services/cache_service.dart';
import '../utils/result.dart';

/// Base class for all repositories in the OTT Stream platform.
/// Orchestrates Caching, Retries, and Error Mapping globally.
abstract class RepositoryBase {
  final CacheService cacheService;
  final RetryPolicy retryPolicy;
  final Logger logger;

  RepositoryBase({
    required this.cacheService,
    required this.retryPolicy,
    required this.logger,
  });

  /// Executes a remote call with optional caching and automatic retries.
  /// [T] is the domain entity type.
  /// [request] is the future-returning function to fetch remote data.
  /// [cacheKey] if provided, will check memory cache first and save successful results.
  Future<Result<T>> safeCall<T>({
    required Future<T> Function() request,
    String? cacheKey,
    bool useRetry = true,
    Duration? ttl,
  }) async {
    // 1. Check Memory Cache first
    if (cacheKey != null) {
      final cachedData = cacheService.get<T>(cacheKey);
      if (cachedData != null) {
        logger.d('RepositoryBase: Returning cached data for [$cacheKey]');
        return Result.success(cachedData);
      }
    }

    try {
      // 2. Execute with Retry Policy
      final T remoteData = useRetry 
          ? await retryPolicy.execute(request)
          : await request();

      // 3. Update Cache if successful
      if (cacheKey != null) {
        cacheService.set(cacheKey, remoteData, ttl: ttl ?? CacheService.defaultTTL);
      }

      return Result.success(remoteData);
    } catch (e, stack) {
      logger.e('RepositoryBase Error: $e', error: e, stackTrace: stack);
      return Result.failure(ErrorMapper.map(e));
    }
  }

  /// Helper for pagination - standardizes the logic for infinite scroll queries.
  Future<Result<List<T>>> paginateCall<T>({
    required Future<List<T>> Function() request,
  }) async {
    try {
      final data = await request();
      return Result.success(data);
    } catch (e) {
      return Result.failure(ErrorMapper.map(e));
    }
  }
}
