import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/video_source_model.dart';

/// Remote data source for video source information, specifically optimized for Cloudflare Stream.
class PlayerService {
  final FirebaseFirestore _firestore;

  PlayerService(this._firestore);

  Future<VideoSourceModel> getVideoSource(String movieId, {bool isTrailer = false}) async {
    final doc = await _firestore.collection('movies').doc(movieId).get();
    if (!doc.exists) throw Exception('Content not found in library');
    
    final data = doc.data()!;
    final videoId = isTrailer ? data['trailerVideoId'] : data['movieVideoId'];
    final playbackUrl = isTrailer ? data['trailerPlaybackUrl'] : data['moviePlaybackUrl'];
    final title = isTrailer ? '${data['title'] ?? 'Unknown'} - Trailer' : (data['title'] ?? 'Unknown');

    if (videoId != null && videoId.toString().isNotEmpty) {
      final hlsUrl = playbackUrl ?? 'https://customer-vdyo74k9rxtpx760.cloudflarestream.com/$videoId/manifest/video.m3u8';
      return VideoSourceModel(
        id: movieId,
        title: title,
        url: hlsUrl,
        type: 'hls',
        subtitleUrl: data['subtitleUrl'],
        thumbnailUrl: data['thumbnailUrl'] ?? 'https://customer-vdyo74k9rxtpx760.cloudflarestream.com/$videoId/thumbnails/thumbnail.jpg',
      );
    }

    final directUrl = playbackUrl ?? data['videoUrl'];
    if (directUrl == null) throw Exception('No playback source available for this content');

    return VideoSourceModel(
      id: movieId,
      title: title,
      url: directUrl,
      type: directUrl.toString().contains('.m3u8') ? 'hls' : 'mp4',
      subtitleUrl: data['subtitleUrl'],
    );
  }

  /// Updates playback progress with 90% completion detection and exact schema alignment.
  Future<void> updatePlaybackPosition({
    required String userId,
    required String movieId,
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    final double progress = totalDurationSeconds > 0 ? positionSeconds / totalDurationSeconds : 0;
    final bool isFinished = progress >= 0.90; // 90% Watched Detection
    
    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(userId);
    final cwRef = userRef.collection('continueWatching').doc(movieId);
    final historyRef = userRef.collection('watchHistory').doc(movieId);
    
    if (isFinished) {
      // Remove from Continue Watching if completed
      batch.delete(cwRef);
      
      // Update Watch History with completion details
      batch.set(historyRef, {
        'userId': userId,
        'movieId': movieId,
        'completedAt': FieldValue.serverTimestamp(),
        'watchDuration': positionSeconds,
        'completed': true,
      }, SetOptions(merge: true));
    } else {
      // Update Continue Watching
      batch.set(cwRef, {
        'userId': userId,
        'movieId': movieId,
        'currentPosition': positionSeconds,
        'duration': totalDurationSeconds,
        'progressPercentage': progress,
        'lastPlayed': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Ensure history tracks the start/progress
      batch.set(historyRef, {
        'userId': userId,
        'movieId': movieId,
        'startedAt': FieldValue.serverTimestamp(),
        'watchDuration': positionSeconds,
        'completed': false,
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Future<int> getPlaybackPosition(String userId, String movieId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('continueWatching')
        .doc(movieId)
        .get();
    
    if (doc.exists) {
      return (doc.data()?['currentPosition'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }
}
