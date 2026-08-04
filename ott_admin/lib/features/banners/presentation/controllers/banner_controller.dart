import 'package:flutter/material.dart';
import '../../domain/entities/admin_banner_entity.dart';
import '../providers/banner_provider.dart';

/// Controller for Banner Management UI logic.
class BannerController {
  final AdminBannerProvider _provider;

  BannerController(this._provider);

  Future<void> init() async {
    await _provider.fetchBanners();
  }

  void onSearchChanged(String query) {
    // Logic for local filtering if needed
  }

  Future<void> onReorder(int oldIndex, int newIndex) async {
    final List<AdminBannerEntity> items = List.from(_provider.banners);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    
    await _provider.updatePriorities(items.map((e) => e.id).toList());
  }

  Future<void> onDelete(String id) async {
    await _provider.deleteBanner(id);
  }
}
