import 'package:logger/logger.dart';

/// A high-performance in-memory cache service with TTL (Time To Live) support.
/// Optimized for OTT metadata like movie details and search results.
class CacheService {
  final Logger _logger;
  final Map<String, _CacheEntry> _cache = {};

  CacheService(this._logger);

  /// Default TTL of 5 minutes for metadata
  static const Duration defaultTTL = Duration(minutes: 5);

  /// Saves data to memory cache.
  void set<T>(String key, T data, {Duration ttl = defaultTTL}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiry: DateTime.now().add(ttl),
    );
    _logger.d('CacheService: Saved entry for key [$key]');
  }

  /// Retrieves data from memory cache if not expired.
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiry)) {
      _logger.d('CacheService: Entry expired for key [$key]');
      _cache.remove(key);
      return null;
    }

    _logger.d('CacheService: Hit for key [$key]');
    return entry.data as T;
  }

  /// Clears specific key or entire cache.
  void clear({String? key}) {
    if (key != null) {
      _cache.remove(key);
    } else {
      _cache.clear();
    }
  }

  /// Removes all expired entries to free up memory.
  void cleanup() {
    _cache.removeWhere((key, entry) => DateTime.now().isAfter(entry.expiry));
  }
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});
}
