import 'package:flutter/material.dart';

/// Model representing user preferences for the video player.
class PlayerSettings {
  final double subtitleFontSize;
  final Color subtitleColor;
  final Color subtitleBackgroundColor;
  final Duration subtitleDelay;
  final Duration audioDelay;
  final bool autoPlayNext;

  const PlayerSettings({
    this.subtitleFontSize = 16.0,
    this.subtitleColor = Colors.white,
    this.subtitleBackgroundColor = Colors.black54,
    this.subtitleDelay = Duration.zero,
    this.audioDelay = Duration.zero,
    this.autoPlayNext = true,
  });

  PlayerSettings copyWith({
    double? subtitleFontSize,
    Color? subtitleColor,
    Color? subtitleBackgroundColor,
    Duration? subtitleDelay,
    Duration? audioDelay,
    bool? autoPlayNext,
  }) {
    return PlayerSettings(
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      subtitleBackgroundColor: subtitleBackgroundColor ?? this.subtitleBackgroundColor,
      subtitleDelay: subtitleDelay ?? this.subtitleDelay,
      audioDelay: audioDelay ?? this.audioDelay,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
    );
  }
}
