import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../users/domain/entities/admin_user_entity.dart';
import '../../../movies/domain/entities/admin_movie_entity.dart';

class DashboardService {
  final FirebaseFirestore _firestore;

  DashboardService(this._firestore);

  Future<Map<String, dynamic>> fetchPlatformStats() async {
    // Basic counts
    final users = await _firestore.collection('users').count().get();
    final movies = await _firestore.collection('movies').count().get();
    final publishedMovies = await _firestore.collection('movies').where('status', isEqualTo: 'published').count().get();
    final trendingMovies = await _firestore.collection('movies').where('isTrending', isEqualTo: true).count().get();
    final featuredMovies = await _firestore.collection('movies').where('isFeatured', isEqualTo: true).count().get();
    
    final categories = await _firestore.collection('categories').count().get();
    final genres = await _firestore.collection('genres').count().get();
    final languages = await _firestore.collection('languages').count().get();
    final countries = await _firestore.collection('countries').count().get();
    final notifications = await _firestore.collection('notifications').count().get();

    // Active User Estimates
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = now.subtract(const Duration(days: 7));
    final monthAgo = now.subtract(const Duration(days: 30));

    final activeToday = await _firestore.collection('users').where('lastActive', isGreaterThanOrEqualTo: todayStart).count().get();
    final activeWeekly = await _firestore.collection('users').where('lastActive', isGreaterThanOrEqualTo: weekAgo).count().get();
    final activeMonthly = await _firestore.collection('users').where('lastActive', isGreaterThanOrEqualTo: monthAgo).count().get();

    // Watch stats
    final globalAnalytics = await _firestore.collection('analytics').doc('global').get();
    final analyticsData = globalAnalytics.data() ?? {};

    return {
      'totalUsers': users.count ?? 0,
      'activeUsersToday': activeToday.count ?? 0,
      'activeUsersWeekly': activeWeekly.count ?? 0,
      'activeUsersMonthly': activeMonthly.count ?? 0,
      
      'totalMovies': movies.count ?? 0,
      'publishedMovies': publishedMovies.count ?? 0,
      'draftMovies': (movies.count ?? 0) - (publishedMovies.count ?? 0),
      'trendingMovies': trendingMovies.count ?? 0,
      'featuredMovies': featuredMovies.count ?? 0,
      
      'totalCategories': categories.count ?? 0,
      'totalGenres': genres.count ?? 0,
      'totalLanguages': languages.count ?? 0,
      'totalCountries': countries.count ?? 0,
      
      'totalWatchHours': (analyticsData['totalWatchHours'] ?? 0.0).toDouble(),
      'todayWatchHours': (analyticsData['todayWatchHours'] ?? 0.0).toDouble(),
      'totalNotifications': notifications.count ?? 0,
      
      'storageUsedGB': (analyticsData['storageUsedGB'] ?? 0.0).toDouble(),
      'bandwidthUsedTB': (analyticsData['bandwidthUsedTB'] ?? 0.0).toDouble(),
    };
  }

  Future<List<AdminUserEntity>> getRecentUsers({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdminUserEntity(
        uid: doc.id,
        fullName: data['fullName'] ?? 'Unknown User',
        email: data['email'] ?? '',
        phone: data['phone'],
        profileImage: data['photoUrl'] ?? data['profileImage'],
        isBlocked: data['isBlocked'] ?? false,
        isEmailVerified: data['isEmailVerified'] ?? false,
        isGuest: data['isGuest'] ?? false,
        watchTimeMinutes: data['watchTimeMinutes'] ?? 0,
        deviceCount: data['deviceCount'] ?? 0,
        downloadCount: data['downloadCount'] ?? 0,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<List<AdminMovieEntity>> getRecentMovies({int limit = 5}) async {
    final snapshot = await _firestore
        .collection('movies')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return AdminMovieEntity(
        id: doc.id,
        title: data['title'] ?? '',
        originalTitle: data['originalTitle'],
        description: data['description'] ?? '',
        shortDescription: data['shortDescription'] ?? '',
        posterUrl: data['posterUrl'] ?? '',
        bannerUrl: data['bannerUrl'] ?? '',
        logoUrl: data['logoUrl'],
        thumbnailUrl: data['thumbnailUrl'],
        genreIds: List<String>.from(data['genreIds'] ?? []),
        categoryIds: List<String>.from(data['categoryIds'] ?? []),
        language: data['language'] ?? 'English',
        country: data['country'] ?? 'USA',
        director: data['director'] ?? 'Unknown',
        producer: data['producer'] ?? 'Unknown',
        writer: data['writer'] ?? 'Unknown',
        musicDirector: data['musicDirector'] ?? 'Unknown',
        duration: data['duration'] is int ? data['duration'] : 0,
        releaseDate: data['releaseDate'] ?? '',
        ageRating: data['ageRating'] ?? 'G',
        imdbRating: (data['rating'] ?? data['imdbRating'] ?? 0.0).toDouble(),
        status: data['status'] == 'published' ? AdminMovieStatus.published : AdminMovieStatus.draft,
        isFeatured: data['isFeatured'] ?? false,
        isTrending: data['isTrending'] ?? false,
        isEditorsChoice: data['isEditorsChoice'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }
}
