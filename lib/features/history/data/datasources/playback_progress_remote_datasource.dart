import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playback_progress_model.dart';

abstract class PlaybackProgressRemoteDataSource {
  Future<void> saveProgress(String userId, PlaybackProgressModel progress);
  Future<PlaybackProgressModel?> getProgress(String userId, String movieId);
  Future<List<PlaybackProgressModel>> getAllProgress(String userId);
  Stream<List<PlaybackProgressModel>> watchContinueWatching(String userId);
  Stream<List<PlaybackProgressModel>> watchWatchHistory(String userId);
  Future<void> deleteProgress(String userId, String movieId);
}

class PlaybackProgressRemoteDataSourceImpl implements PlaybackProgressRemoteDataSource {
  final FirebaseFirestore _firestore;

  PlaybackProgressRemoteDataSourceImpl(this._firestore);

  DocumentReference _userDoc(String userId) => _firestore.collection('users').doc(userId);

  @override
  Future<void> saveProgress(String userId, PlaybackProgressModel progress) async {
    final batch = _firestore.batch();
    // Unified with firestore.rules: continue_watching and watch_history
    final cwRef = _userDoc(userId).collection('continue_watching').doc(progress.movieId);
    final historyRef = _userDoc(userId).collection('watch_history').doc(progress.movieId);

    if (progress.isCompleted) {
      batch.delete(cwRef);
      batch.set(historyRef, {
        'userId': userId,
        'movieId': progress.movieId,
        'completedAt': FieldValue.serverTimestamp(),
        'watchDuration': progress.lastPosition.inSeconds,
        'completed': true,
      }, SetOptions(merge: true));
    } else {
      batch.set(cwRef, {
        'userId': userId,
        'movieId': progress.movieId,
        'currentPosition': progress.lastPosition.inSeconds,
        'duration': progress.totalDuration.inSeconds,
        'progressPercentage': progress.percentage,
        'lastPlayed': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      batch.set(historyRef, {
        'userId': userId,
        'movieId': progress.movieId,
        'startedAt': FieldValue.serverTimestamp(),
        'watchDuration': progress.lastPosition.inSeconds,
        'completed': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  @override
  Future<PlaybackProgressModel?> getProgress(String userId, String movieId) async {
    final cwDoc = await _userDoc(userId).collection('continue_watching').doc(movieId).get();
    if (cwDoc.exists) {
      final data = cwDoc.data()!;
      return PlaybackProgressModel(
        movieId: movieId,
        lastPosition: Duration(seconds: data['currentPosition'] ?? 0),
        totalDuration: Duration(seconds: data['duration'] ?? 0),
        percentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
        lastPlayedTime: (data['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isCompleted: false,
      );
    }
    
    final historyDoc = await _userDoc(userId).collection('watch_history').doc(movieId).get();
    if (historyDoc.exists) {
      final data = historyDoc.data()!;
      return PlaybackProgressModel(
        movieId: movieId,
        lastPosition: Duration(seconds: data['watchDuration'] ?? 0),
        totalDuration: Duration(seconds: data['watchDuration'] ?? 0),
        percentage: (data['completed'] == true) ? 1.0 : 0.0,
        lastPlayedTime: (data['completedAt'] as Timestamp? ?? data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isCompleted: data['completed'] ?? false,
      );
    }
    return null;
  }

  @override
  Future<List<PlaybackProgressModel>> getAllProgress(String userId) async {
    final historySnapshot = await _userDoc(userId).collection('watch_history').get();
    return historySnapshot.docs.map((doc) {
      final data = doc.data();
      return PlaybackProgressModel(
        movieId: doc.id,
        lastPosition: Duration(seconds: data['watchDuration'] ?? 0),
        totalDuration: Duration(seconds: data['watchDuration'] ?? 0),
        percentage: (data['completed'] == true) ? 1.0 : 0.0,
        lastPlayedTime: (data['completedAt'] as Timestamp? ?? data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isCompleted: data['completed'] ?? false,
      );
    }).toList();
  }

  @override
  Stream<List<PlaybackProgressModel>> watchContinueWatching(String userId) {
    return _userDoc(userId)
        .collection('continue_watching')
        .orderBy('lastPlayed', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PlaybackProgressModel(
                movieId: doc.id,
                lastPosition: Duration(seconds: data['currentPosition'] ?? 0),
                totalDuration: Duration(seconds: data['duration'] ?? 0),
                percentage: (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
                lastPlayedTime: (data['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isCompleted: false,
              );
            }).toList());
  }

  @override
  Stream<List<PlaybackProgressModel>> watchWatchHistory(String userId) {
    return _userDoc(userId)
        .collection('watch_history')
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return PlaybackProgressModel(
                movieId: doc.id,
                lastPosition: Duration(seconds: data['watchDuration'] ?? 0),
                totalDuration: Duration(seconds: data['watchDuration'] ?? 0),
                percentage: (data['completed'] == true) ? 1.0 : 0.0,
                lastPlayedTime: (data['completedAt'] as Timestamp? ?? data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
                isCompleted: data['completed'] ?? false,
              );
            }).toList());
  }

  @override
  Future<void> deleteProgress(String userId, String movieId) async {
    final batch = _firestore.batch();
    batch.delete(_userDoc(userId).collection('continue_watching').doc(movieId));
    batch.delete(_userDoc(userId).collection('watch_history').doc(movieId));
    await batch.commit();
  }
}
