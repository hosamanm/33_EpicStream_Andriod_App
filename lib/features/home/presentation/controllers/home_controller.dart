import '../../domain/repositories/home_repository.dart';
import '../providers/home_provider.dart';
import '../providers/home_state.dart';
import '../../../history/data/services/continue_watching_service.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/genre_entity.dart';
import 'package:get_it/get_it.dart';

/// Production-grade Controller for the Home Screen.
/// Orchestrates data fetching from Repository and ContinueWatching service.
class HomeController {
  final HomeProvider _provider;
  final HomeRepository _repository;
  final ContinueWatchingService _continueWatchingService;

  HomeController(
    this._provider, 
    this._repository, 
    this._continueWatchingService,
  );

  Future<void> fetchHomeData() async {
    // Avoid multiple simultaneous fetches
    if (_provider.state is HomeLoading) return;

    _provider.setState(HomeLoading());

    try {
      // Parallel execution for better performance
      final results = await Future.wait([
        _repository.getHeroBanners(),
        _repository.getTrendingMovies(),
        _repository.getPopularMovies(),
        _repository.getLatestMovies(),
        _continueWatchingService.getContinueWatchingList(),
        _repository.getCategories(),
        _repository.getGenres(),
      ]);

      // Handle recommendations based on user profile
      final profile = GetIt.I<ProfileProvider>().profile;
      final recommended = await _repository.getRecommendedMovies(
        profile?.favoriteGenres ?? [],
      );

      _provider.setState(HomeLoaded(
        heroBanners: results[0] as List<MovieEntity>,
        trending: results[1] as List<MovieEntity>,
        popular: results[2] as List<MovieEntity>,
        latest: results[3] as List<MovieEntity>,
        continueWatching: results[4] as List<MovieEntity>,
        categories: results[5] as List<CategoryEntity>,
        genres: results[6] as List<GenreEntity>,
        recommended: recommended,
      ));
    } catch (e) {
      _provider.setState(HomeError('Failed to load cinematic content: ${e.toString()}'));
    }
  }
}
