import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/download_model.dart';

abstract class DownloadLocalDataSource {
  Future<List<DownloadModel>> getDownloads();
  Future<void> saveDownload(DownloadModel download);
  Future<void> deleteDownload(String id);
  Future<void> updateDownload(DownloadModel download);
}

class DownloadLocalDataSourceImpl implements DownloadLocalDataSource {
  final SharedPreferences _prefs;
  static const String _key = 'downloaded_items';

  DownloadLocalDataSourceImpl(this._prefs);

  @override
  Future<List<DownloadModel>> getDownloads() async {
    final String? data = _prefs.getString(_key);
    if (data == null) return [];
    
    final List<dynamic> list = json.decode(data);
    return list.map((json) => DownloadModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveDownload(DownloadModel download) async {
    final downloads = await getDownloads();
    downloads.add(download);
    await _prefs.setString(_key, json.encode(downloads.map((e) => e.toJson()).toList()));
  }

  @override
  Future<void> updateDownload(DownloadModel download) async {
    final downloads = await getDownloads();
    final index = downloads.indexWhere((e) => e.id == download.id);
    if (index != -1) {
      downloads[index] = download;
      await _prefs.setString(_key, json.encode(downloads.map((e) => e.toJson()).toList()));
    }
  }

  @override
  Future<void> deleteDownload(String id) async {
    final downloads = await getDownloads();
    downloads.removeWhere((e) => e.id == id);
    await _prefs.setString(_key, json.encode(downloads.map((e) => e.toJson()).toList()));
  }
}
