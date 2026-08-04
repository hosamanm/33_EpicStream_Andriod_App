import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';

/// Strategy for retrying failed network requests using Exponential Backoff.
class RetryPolicy {
  final Logger _logger;
  final int maxRetries;
  final Duration baseDelay;

  RetryPolicy(this._logger, {this.maxRetries = 3, this.baseDelay = const Duration(seconds: 2)});

  /// Executes a task with automatic retries on failure.
  Future<T> execute<T>(Future<T> Function() task) async {
    int attempts = 0;
    
    while (true) {
      try {
        return await task();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          _logger.e('RetryPolicy: Max retries reached ($maxRetries). failing...');
          rethrow;
        }

        // Calculate delay: baseDelay * 2^attempts + random jitter
        final jitter = Random().nextInt(1000);
        final delay = Duration(
          milliseconds: (baseDelay.inMilliseconds * pow(2, attempts)).toInt() + jitter,
        );
        
        _logger.w('RetryPolicy: Task failed. Retrying in ${delay.inSeconds}s... (Attempt $attempts/$maxRetries)');
        await Future.delayed(delay);
      }
    }
  }
}
