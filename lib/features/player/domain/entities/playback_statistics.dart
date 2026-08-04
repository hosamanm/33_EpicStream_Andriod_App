import 'package:equatable/equatable.dart';

/// Entity representing technical playback statistics.
class PlaybackStatistics extends Equatable {
  final String resolution;
  final double fps;
  final double bitrateKbps;
  final Duration bufferDuration;
  final int droppedFrames;
  final String networkType;
  final double downloadSpeedMbps;

  const PlaybackStatistics({
    required this.resolution,
    required this.fps,
    required this.bitrateKbps,
    required this.bufferDuration,
    required this.droppedFrames,
    required this.networkType,
    required this.downloadSpeedMbps,
  });

  @override
  List<Object?> get props => [
        resolution,
        fps,
        bitrateKbps,
        bufferDuration,
        droppedFrames,
        networkType,
        downloadSpeedMbps,
      ];
}
