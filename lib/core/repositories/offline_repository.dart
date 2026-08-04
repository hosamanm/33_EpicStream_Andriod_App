import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

/// Configuration class for Firestore Offline Persistence.
/// Essential for OTT apps to allow users to browse their Watchlist/History offline.
class OfflineRepository {
  final FirebaseFirestore _firestore;
  final Logger _logger;

  OfflineRepository(this._firestore, this._logger);

  /// Initializes Firestore settings for optimal offline performance.
  Future<void> initialize() async {
    try {
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      _logger.i('OfflineRepository: Firestore persistence enabled with unlimited cache.');
    } catch (e) {
      _logger.e('OfflineRepository: Failed to enable persistence', error: e);
    }
  }

  /// Manually clears the local cache if storage is a concern.
  Future<void> clearPersistence() async {
    try {
      await _firestore.clearPersistence();
      _logger.i('OfflineRepository: Local cache cleared.');
    } catch (e) {
      _logger.e('OfflineRepository: Error clearing persistence', error: e);
    }
  }
}
