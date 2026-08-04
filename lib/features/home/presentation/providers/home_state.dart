import 'package:equatable/equatable.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/domain/entities/genre_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MovieEntity> heroBanners;
  final List<MovieEntity> trending;
  final List<MovieEntity> popular;
  final List<MovieEntity> latest;
  final List<MovieEntity> recommended;
  final List<MovieEntity> continueWatching;
  final List<CategoryEntity> categories;
  final List<GenreEntity> genres;

  const HomeLoaded({
    required this.heroBanners,
    required this.trending,
    required this.popular,
    required this.latest,
    required this.recommended,
    required this.continueWatching,
    required this.categories,
    required this.genres,
  });

  @override
  List<Object?> get props => [
        heroBanners,
        trending,
        popular,
        latest,
        recommended,
        continueWatching,
        categories,
        genres,
      ];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
