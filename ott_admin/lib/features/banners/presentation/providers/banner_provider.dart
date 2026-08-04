import 'package:flutter/material.dart';
import '../../domain/entities/admin_banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';

enum BannerManagementStatus { initial, loading, loaded, error }

class AdminBannerProvider extends ChangeNotifier {
  final BannerRepository _repository;

  AdminBannerProvider(this._repository);

  BannerManagementStatus _status = BannerManagementStatus.initial;
  BannerManagementStatus get status => _status;

  List<AdminBannerEntity> _banners = [];
  List<AdminBannerEntity> get banners => _banners;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBanners({BannerType? type}) async {
    _status = BannerManagementStatus.loading;
    notifyListeners();

    final result = await _repository.getBanners(type: type);

    if (result.isSuccess) {
      _banners = result.data;
      _status = BannerManagementStatus.loaded;
    } else {
      _errorMessage = result.failure.message;
      _status = BannerManagementStatus.error;
    }
    notifyListeners();
  }

  Future<void> addBanner(AdminBannerEntity banner) async {
    final result = await _repository.addBanner(banner);
    if (result.isSuccess) {
      await fetchBanners();
    }
  }

  Future<void> updateBanner(AdminBannerEntity banner) async {
    final result = await _repository.updateBanner(banner);
    if (result.isSuccess) {
      await fetchBanners();
    }
  }

  Future<void> deleteBanner(String id) async {
    final result = await _repository.deleteBanner(id);
    if (result.isSuccess) {
      _banners.removeWhere((b) => b.id == id);
      notifyListeners();
    }
  }

  Future<void> updatePriorities(List<String> ids) async {
    await _repository.updateBannerPriorities(ids);
  }
}
