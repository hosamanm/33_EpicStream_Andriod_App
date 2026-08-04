import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppAnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAuth _auth;

  AppAnalyticsService(this._analytics, this._auth);

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logMovieOpen(String movieId, String title) async {
    await _analytics.logEvent(
      name: 'movie_open',
      parameters: {
        'movie_id': movieId,
        'movie_title': title,
        'user_id': _auth.currentUser?.uid ?? 'anonymous',
      },
    );
  }

  Future<void> logMoviePlay(String movieId, String title) async {
    await _analytics.logEvent(
      name: 'movie_play',
      parameters: {
        'movie_id': movieId,
        'movie_title': title,
      },
    );
  }

  Future<void> logMovieComplete(String movieId, String title) async {
    await _analytics.logEvent(
      name: 'movie_complete',
      parameters: {
        'movie_id': movieId,
        'movie_title': title,
      },
    );
  }

  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  Future<void> logFavorite(String movieId, bool isAdded) async {
    await _analytics.logEvent(
      name: 'favorite_action',
      parameters: {
        'movie_id': movieId,
        'action': isAdded ? 'add' : 'remove',
      },
    );
  }

  Future<void> logWatchlist(String movieId, bool isAdded) async {
    await _analytics.logEvent(
      name: 'watchlist_action',
      parameters: {
        'movie_id': movieId,
        'action': isAdded ? 'add' : 'remove',
      },
    );
  }

  Future<void> setUserProperties() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _analytics.setUserId(id: user.uid);
      // Custom properties
      if (user.email != null) {
        await _analytics.setUserProperty(name: 'email', value: user.email);
      }
    }
  }

  Future<void> logNotificationOpen(String notificationId) async {
    await _analytics.logEvent(
      name: 'notification_open',
      parameters: {'notification_id': notificationId},
    );
  }
}
