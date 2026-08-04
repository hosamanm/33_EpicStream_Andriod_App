import 'package:equatable/equatable.dart';
import '../../domain/entities/movie_entity.dart';

sealed class MovieDetailsState extends Equatable {
  const MovieDetailsState();
  @override
  List<Object?> get props => [];
}

class MovieDetailsInitial extends MovieDetailsState {}

class MovieDetailsLoading extends MovieDetailsState {}

class MovieDetailsLoaded extends MovieDetailsState {
  final MovieEntity movie;
  final List<MovieEntity> recommendations;
  final bool isInWatchlist;
  final bool isFavorite;

  const MovieDetailsLoaded({
    required this.movie,
    required this.recommendations,
    this.isInWatchlist = false,
    this.isFavorite = false,
  });

  MovieDetailsLoaded copyWith({
    MovieEntity? movie,
    List<MovieEntity>? recommendations,
    bool? isInWatchlist,
    bool? isFavorite,
  }) {
    return MovieDetailsLoaded(
      movie: movie ?? this.movie,
      recommendations: recommendations ?? this.recommendations,
      isInWatchlist: isInWatchlist ?? this.isInWatchlist,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [movie, recommendations, isInWatchlist, isFavorite];
}

class MovieDetailsError extends MovieDetailsState {
  final String message;
  const MovieDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
