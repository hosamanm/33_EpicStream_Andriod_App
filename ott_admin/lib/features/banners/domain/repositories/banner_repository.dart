import '../../../../core/utils/result.dart';
import '../entities/admin_banner_entity.dart';

abstract class BannerRepository {
  Future<Result<List<AdminBannerEntity>>> getBanners({BannerType? type});
  Future<Result<void>> addBanner(AdminBannerEntity banner);
  Future<Result<void>> updateBanner(AdminBannerEntity banner);
  Future<Result<void>> deleteBanner(String id);
  Future<Result<void>> updateBannerPriorities(List<String> ids);
}
