import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/playback_progress_entity.dart';

class PlaybackProgressModel extends PlaybackProgressEntity {
  const PlaybackProgressModel({
    required super.movieId,
    required super.lastPosition,
    required super.totalDuration,
    required super.percentage,
    required super.lastPlayedTime,
    super.isCompleted,
  });

  factory PlaybackProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlaybackProgressModel(
      movieId: doc.id,
      lastPosition: Duration(seconds: data['lastPositionSeconds'] ?? 0),
      totalDuration: Duration(seconds: data['totalDurationSeconds'] ?? 0),
      percentage: (data['percentage'] as num?)?.toDouble() ?? 0.0,
      lastPlayedTime: (data['lastPlayedTime'] as Timestamp).toDate(),
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'lastPositionSeconds': lastPosition.inSeconds,
      'totalDurationSeconds': totalDuration.inSeconds,
      'percentage': percentage,
      'lastPlayedTime': Timestamp.fromDate(lastPlayedTime),
      'isCompleted': isCompleted,
    };
  }
}
