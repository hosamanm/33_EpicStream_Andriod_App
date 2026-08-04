import 'package:equatable/equatable.dart';

/// Pure business object representing a favorited item.
class FavoriteEntity extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final String type; // 'movie', 'tv_show', 'actor', 'director'
  final DateTime favoritedAt;

  const FavoriteEntity({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.type,
    required this.favoritedAt,
  });

  @override
  List<Object?> get props => [id, title, type, favoritedAt];
}
