import 'package:equatable/equatable.dart';

class PlaybackProgressEntity extends Equatable {
  final String movieId;
  final Duration lastPosition;
  final Duration totalDuration;
  final double percentage; // 0.0 to 1.0
  final DateTime lastPlayedTime;
  final bool isCompleted;

  const PlaybackProgressEntity({
    required this.movieId,
    required this.lastPosition,
    required this.totalDuration,
    required this.percentage,
    required this.lastPlayedTime,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [movieId, lastPosition, totalDuration, percentage, lastPlayedTime, isCompleted];
}
