import '../../domain/entities/banner_item.dart';

class BannerModel extends BannerItem {
  const BannerModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    super.logoUrl,
    required super.genres,
    required super.rating,
    required super.year,
    required super.duration,
    required super.language,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      logoUrl: json['logoUrl'],
      genres: List<String>.from(json['genres']),
      rating: json['rating'],
      year: json['year'],
      duration: json['duration'],
      language: json['language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'genres': genres,
      'rating': rating,
      'year': year,
      'duration': duration,
      'language': language,
    };
  }
}
