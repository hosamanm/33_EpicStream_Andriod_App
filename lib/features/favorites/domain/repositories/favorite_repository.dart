import '../../../../core/utils/result.dart';
import '../entities/favorite_entity.dart';

abstract class FavoriteRepository {
  Future<Result<void>> addFavorite(FavoriteEntity favorite);
  Future<Result<void>> removeFavorite(String id);
  Stream<List<FavoriteEntity>> watchFavorites({String? type});
  Future<Result<bool>> isFavorite(String id);
}
