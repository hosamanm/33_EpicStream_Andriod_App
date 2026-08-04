import 'package:equatable/equatable.dart';

class BannerItem extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? logoUrl;
  final List<String> genres;
  final String rating;
  final String year;
  final String duration;
  final String language;

  const BannerItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.logoUrl,
    required this.genres,
    required this.rating,
    required this.year,
    required this.duration,
    required this.language,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        logoUrl,
        genres,
        rating,
        year,
        duration,
        language,
      ];
}
