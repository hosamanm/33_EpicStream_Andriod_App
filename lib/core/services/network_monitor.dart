import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

enum NetworkQuality { poor, fair, good, excellent }

class NetworkMonitor {
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();
  final Logger _logger;

  NetworkQuality _quality = NetworkQuality.good;
  NetworkQuality get quality => _quality;

  double _currentSpeedMbps = 0.0;
  double get currentSpeedMbps => _currentSpeedMbps;

  Timer? _speedTestTimer;

  NetworkMonitor(this._logger) {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _startSpeedMonitoring();
      } else {
        _stopSpeedMonitoring();
      }
    });
  }

  void _startSpeedMonitoring() {
    _speedTestTimer?.cancel();
    _speedTestTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _measureSpeed();
    });
    _measureSpeed();
  }

  void _stopSpeedMonitoring() {
    _speedTestTimer?.cancel();
  }

  Future<void> _measureSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      // Use a small chunk of a known file or a dedicated speed test endpoint
      final response = await _dio.get(
        'https://fast.com', // Placeholder for actual speed test file
        options: Options(responseType: ResponseType.bytes),
      );
      stopwatch.stop();

      final fileSizeBits = response.data.length * 8;
      final durationSeconds = stopwatch.elapsedMilliseconds / 1000.0;
      _currentSpeedMbps = (fileSizeBits / durationSeconds) / 1000000.0;

      if (_currentSpeedMbps < 2) {
        _quality = NetworkQuality.poor;
      } else if (_currentSpeedMbps < 5) {
        _quality = NetworkQuality.fair;
      } else if (_currentSpeedMbps < 15) {
        _quality = NetworkQuality.good;
      } else {
        _quality = NetworkQuality.excellent;
      }
      
      _logger.d('Network Speed: ${_currentSpeedMbps.toStringAsFixed(2)} Mbps - Quality: $_quality');
    } catch (e) {
      _logger.e('Speed test failed: $e');
    }
  }

  void dispose() {
    _speedTestTimer?.cancel();
  }
}
