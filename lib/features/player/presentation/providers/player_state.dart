import 'package:equatable/equatable.dart';
import '../../domain/entities/video_source_entity.dart';

sealed class VideoPlayerState extends Equatable {
  const VideoPlayerState();
  @override
  List<Object?> get props => [];
}

class PlayerInitial extends VideoPlayerState {}

class PlayerLoading extends VideoPlayerState {}

class PlayerReady extends VideoPlayerState {
  final VideoSourceEntity source;
  const PlayerReady(this.source);
  @override
  List<Object?> get props => [source];
}

class PlayerBuffering extends VideoPlayerState {}

class PlayerError extends VideoPlayerState {
  final String message;
  const PlayerError(this.message);
  @override
  List<Object?> get props => [message];
}
