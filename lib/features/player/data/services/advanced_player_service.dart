import 'dart:async';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';

/// Service responsible for advanced player logic like PiP, Sleep Timer, and Casting.
class AdvancedPlayerService {
  Timer? _sleepTimer;
  final ValueNotifier<Duration?> sleepTimerRemaining = ValueNotifier(null);

  /// Enables Picture-in-Picture mode using BetterPlayer's native support.
  void enablePiP(BetterPlayerController controller) {
    controller.enablePictureInPicture(controller.betterPlayerGlobalKey!);
  }

  /// Sets a sleep timer that pauses playback after a specified duration.
  void setSleepTimer(Duration duration, BetterPlayerController controller) {
    _sleepTimer?.cancel();
    sleepTimerRemaining.value = duration;

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (sleepTimerRemaining.value == null || sleepTimerRemaining.value!.inSeconds <= 0) {
        timer.cancel();
        sleepTimerRemaining.value = null;
        controller.pause();
      } else {
        sleepTimerRemaining.value = sleepTimerRemaining.value! - const Duration(seconds: 1);
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    sleepTimerRemaining.value = null;
  }

  /// Placeholder for Casting logic (e.g., Google Cast / AirPlay).
  /// In a production app, this would integrate with flutter_cast or similar.
  void startCasting(String movieId) {
    // Logic to discover devices and send stream URL
  }

  void dispose() {
    _sleepTimer?.cancel();
    sleepTimerRemaining.dispose();
  }
}
