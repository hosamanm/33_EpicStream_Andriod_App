import '../../domain/repositories/watchlist_repository.dart';
import '../providers/watchlist_provider.dart';

class WatchlistController {
  final WatchlistRepository _repository;
  final WatchlistProvider _provider;

  WatchlistController(this._repository, this._provider);

  Future<void> toggleWatchlist(String movieId) async {
    final isInWatchlistResult = await _repository.isInWatchlist(movieId);
    if (isInWatchlistResult.isSuccess) {
      if (isInWatchlistResult.data!) {
        await _repository.removeFromWatchlist(movieId);
      } else {
        await _repository.addToWatchlist(movieId);
      }
    }
  }

  void refresh() => _provider.fetchWatchlist();
}
