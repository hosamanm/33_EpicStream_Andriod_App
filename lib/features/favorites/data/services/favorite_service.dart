import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';

/// Orchestrates favorite operations and potentially integrates with analytics.
class FavoriteService {
  final FavoriteRepository _repository;

  FavoriteService(this._repository);

  Future<void> toggleFavorite(FavoriteEntity item) async {
    final isFavResult = await _repository.isFavorite(item.id);
    if (isFavResult.isSuccess) {
      if (isFavResult.data) {
        await _repository.removeFavorite(item.id);
      } else {
        await _repository.addFavorite(item);
      }
    }
  }

  Stream<List<FavoriteEntity>> getUserFavorites({String? type}) {
    return _repository.watchFavorites(type: type);
  }
}
