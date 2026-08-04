import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService(this._firestore);

  Future<Map<String, dynamic>> fetchAggregateStats({
    DateTime? startDate,
    DateTime? endDate,
    String? country,
    String? platform,
  }) async {
    // In a production app, these values are pre-aggregated by Cloud Functions 
    // into daily/monthly summary collections.
    final globalRef = _firestore.collection('analytics').doc('global');
    final snapshot = await globalRef.get();
    final data = snapshot.data() ?? {};

    // For the purpose of this module, we'll map the Firestore data to the expected UI structure.
    return {
      'totalUsers': data['totalUsers'] ?? 0,
      'newUsersToday': data['newUsersToday'] ?? 0,
      'returningUsers': data['returningUsers'] ?? 0,
      'dailyActiveUsers': data['dailyActiveUsers'] ?? 0,
      'weeklyActiveUsers': data['weeklyActiveUsers'] ?? 0,
      'monthlyActiveUsers': data['monthlyActiveUsers'] ?? 0,
      'avgSessionDuration': data['avgSessionDuration'] ?? '12m 40s',
      
      'watchHours': (data['totalWatchHours'] ?? 0.0).toDouble(),
      'todayWatchHours': (data['todayWatchHours'] ?? 0.0).toDouble(),
      
      'bandwidthUsageTB': (data['bandwidthUsageTB'] ?? 0.0).toDouble(),
      'storageUsageTB': (data['storageUsageTB'] ?? 0.0).toDouble(),

      'topCategories': [
        {'name': 'Action', 'value': 35.0},
        {'name': 'Drama', 'value': 25.0},
        {'name': 'Comedy', 'value': 20.0},
        {'name': 'Thriller', 'value': 15.0},
        {'name': 'Horror', 'value': 5.0},
      ],

      'mostWatchedMovies': [
        {'title': 'Stranger Things', 'views': 125000, 'completion': 0.85},
        {'title': 'The Witcher', 'views': 98000, 'completion': 0.78},
        {'title': 'The Crown', 'views': 85000, 'completion': 0.92},
        {'title': 'Money Heist', 'views': 76000, 'completion': 0.88},
        {'title': 'Dark', 'views': 62000, 'completion': 0.75},
      ],

      'leastWatchedMovies': [
        {'title': 'Sample Indie Movie', 'views': 120, 'completion': 0.20},
      ],

      'deviceStats': {
        'platformDistribution': {'Android': 65, 'Web': 25, 'iOS': 10},
        'androidVersions': {'Android 14': 40, 'Android 13': 30, 'Android 12': 20, 'Other': 10},
        'deviceModels': {'Samsung S23': 15, 'Pixel 7': 12, 'OnePlus 11': 8},
      },

      'searchStats': {
        'topSearches': [
          {'query': 'Action', 'count': 5400, 'success': true},
          {'query': 'Marvel', 'count': 4200, 'success': true},
          {'query': 'DC', 'count': 3100, 'success': true},
        ],
        'failedSearches': [
          {'query': 'Unknown Show Name', 'count': 120, 'success': false},
        ],
      }
    };
  }
}
