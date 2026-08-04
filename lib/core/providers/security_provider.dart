import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../services/app_check_service.dart';

enum SecurityStatus { checking, secure, compromised, error }

/// Provider to manage and expose the security state of the application.
class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;
  final AppCheckService _appCheckService;

  SecurityProvider(this._securityService, this._appCheckService);

  SecurityStatus _status = SecurityStatus.checking;
  SecurityStatus get status => _status;

  String? _violationMessage;
  String? get violationMessage => _violationMessage;

  /// Performs a full security audit of the device and app integrity.
  Future<void> performSecurityCheck() async {
    _status = SecurityStatus.checking;
    notifyListeners();

    try {
      // 1. Initialize App Check (Enforces authentic requests)
      await _appCheckService.initialize();

      // 2. Perform Device Integrity Checks (Root/Jailbreak/Emulator)
      final isSecure = await _securityService.isDeviceSecure();

      if (isSecure) {
        _status = SecurityStatus.secure;
      } else {
        _status = SecurityStatus.compromised;
        _violationMessage = 'Device integrity check failed. For your security, this app cannot run on rooted or emulated devices.';
      }
    } catch (e) {
      _status = SecurityStatus.error;
      _violationMessage = 'Security initialization failed: $e';
    }

    notifyListeners();
  }
}
