import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

enum ConnectivityStatus { wifi, cellular, offline }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger;
  
  final StreamController<ConnectivityStatus> _statusController = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityService(this._logger) {
    // connectivity_plus version in pubspec is ^5.0.2, 
    // which returns a single ConnectivityResult, not a List.
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _statusController.add(_getStatusFromResult(result));
    });
  }

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;

  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _getStatusFromResult(result);
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return ConnectivityStatus.offline;
    }
  }

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.vpn:
      case ConnectivityResult.other:
        _logger.d('Connectivity: High Speed');
        return ConnectivityStatus.wifi;
      case ConnectivityResult.mobile:
        _logger.d('Connectivity: Cellular');
        return ConnectivityStatus.cellular;
      case ConnectivityResult.none:
      default:
        _logger.w('Connectivity: Offline');
        return ConnectivityStatus.offline;
    }
  }

  void dispose() {
    _statusController.close();
  }
}
