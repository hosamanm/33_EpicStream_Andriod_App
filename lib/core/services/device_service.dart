import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Captures device and application metadata for security and analytics.
class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final Map<String, dynamic> data = {
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': Platform.isAndroid ? 'android' : 'ios',
    };

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      data.addAll({
        'device': androidInfo.model,
        'osVersion': androidInfo.version.release,
        'manufacturer': androidInfo.manufacturer,
        'deviceId': androidInfo.id,
      });
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      data.addAll({
        'device': iosInfo.name,
        'osVersion': iosInfo.systemVersion,
        'manufacturer': 'Apple',
        'deviceId': iosInfo.identifierForVendor,
      });
    }

    return data;
  }
}
