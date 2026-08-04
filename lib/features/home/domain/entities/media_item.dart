import 'package:equatable/equatable.dart';

class MediaItem extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final String? backdropUrl;
  final String? rating;
  final String? year;

  const MediaItem({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.year,
  });

  @override
  List<Object?> get props => [id, title, posterUrl, backdropUrl, rating, year];
}
