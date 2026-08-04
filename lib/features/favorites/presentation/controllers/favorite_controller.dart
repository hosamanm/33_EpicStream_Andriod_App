import '../../domain/entities/favorite_entity.dart';
import '../../data/services/favorite_service.dart';
import '../providers/favorite_provider.dart';

/// Controller to handle user interactions for the Favorites module.
/// It bridges the UI and the Service layer.
class FavoriteController {
  final FavoriteService _favoriteService;
  final FavoriteProvider _provider;

  FavoriteController({
    required FavoriteService favoriteService,
    required FavoriteProvider provider,
  })  : _favoriteService = favoriteService,
        _provider = provider;

  /// Toggles the favorite status of a movie or actor.
  Future<void> toggleFavorite(FavoriteEntity item) async {
    await _favoriteService.toggleFavorite(item);
    // Real-time updates are handled by the provider's stream subscription.
  }

  /// Sets the current tab in the Favorites screen.
  void changeTab(FavoriteTab tab) {
    _provider.setTab(tab);
  }

  /// Refreshes the favorites list.
  void refresh() {
    _provider.init();
  }
}
