import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_banner_entity.dart';
import '../../domain/repositories/banner_repository.dart';
import '../models/admin_banner_model.dart';
import '../services/admin_banner_service.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminBannerRepositoryImpl implements BannerRepository {
  final AdminBannerService _service;
  final ActivityLogRepository _logRepository;
  final FirebaseAuth _auth;

  AdminBannerRepositoryImpl(this._service, this._logRepository, this._auth);

  String get _adminEmail => _auth.currentUser?.email ?? 'system';
  String get _adminId => _auth.currentUser?.uid ?? 'system';

  @override
  Future<Result<List<AdminBannerEntity>>> getBanners({BannerType? type}) async {
    try {
      final models = await _service.fetchBanners(type: type);
      return Result.success(models);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addBanner(AdminBannerEntity banner) async {
    try {
      final model = AdminBannerModel(
        id: '',
        title: banner.title,
        description: banner.description,
        mobileImageUrl: banner.mobileImageUrl,
        tabletImageUrl: banner.tabletImageUrl,
        desktopImageUrl: banner.desktopImageUrl,
        type: banner.type,
        status: banner.status,
        targetType: banner.targetType,
        targetValue: banner.targetValue,
        startDate: banner.startDate,
        endDate: banner.endDate,
        priority: banner.priority,
      );
      await _service.saveBanner(model);

      await _logAction(ActivityAction.upload, ActivityModule.banners, banner.title, 'Created new banner: ${banner.title}');

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateBanner(AdminBannerEntity banner) async {
    try {
      final model = AdminBannerModel(
        id: banner.id,
        title: banner.title,
        description: banner.description,
        mobileImageUrl: banner.mobileImageUrl,
        tabletImageUrl: banner.tabletImageUrl,
        desktopImageUrl: banner.desktopImageUrl,
        type: banner.type,
        status: banner.status,
        targetType: banner.targetType,
        targetValue: banner.targetValue,
        startDate: banner.startDate,
        endDate: banner.endDate,
        priority: banner.priority,
      );
      await _service.saveBanner(model);

      await _logAction(ActivityAction.edit, ActivityModule.banners, banner.id, 'Updated banner: ${banner.title}');

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteBanner(String id) async {
    try {
      await _service.deleteBanner(id);
      await _logAction(ActivityAction.delete, ActivityModule.banners, id, 'Deleted banner');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateBannerPriorities(List<String> ids) async {
    try {
      await _service.updatePriorities(ids);
      await _logAction(ActivityAction.edit, ActivityModule.banners, 'batch', 'Reordered banners');
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  Future<void> _logAction(ActivityAction action, ActivityModule module, String targetId, String description) async {
    await _logRepository.logAction(ActivityLogEntity(
      id: '',
      adminId: _adminId,
      adminEmail: _adminEmail,
      action: action,
      module: module,
      targetId: targetId,
      description: description,
      ipAddress: '0.0.0.0',
      timestamp: DateTime.now(),
    ));
  }
}
