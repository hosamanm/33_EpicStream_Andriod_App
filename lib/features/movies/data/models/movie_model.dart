import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/entities/cast_member.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.movieId,
    required super.title,
    super.originalTitle,
    required super.shortDescription,
    required super.longDescription,
    super.movieVideoId,
    super.moviePlaybackUrl,
    super.trailerVideoId,
    super.trailerPlaybackUrl,
    super.thumbnailUrl,
    required super.posterUrl,
    required super.bannerUrl,
    super.logoUrl,
    required super.categoryId,
    required super.genreIds,
    required super.genreNames,
    required super.language,
    required super.availableLanguages,
    required super.subtitleLanguages,
    required super.duration,
    super.releaseDate,
    required super.releaseYear,
    required super.ageRating,
    required super.imdbRating,
    super.userRating,
    required super.cast,
    super.crew,
    required super.director,
    super.producer,
    super.writer,
    super.musicDirector,
    super.studio,
    super.country,
    super.status = 'published',
    super.isFeatured = false,
    super.isTrending = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MovieModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Improved Date Parsing to handle Admin vs App differences
    DateTime? parsedDate;
    if (data['releaseDate'] is Timestamp) {
      parsedDate = (data['releaseDate'] as Timestamp).toDate();
    } else if (data['releaseDate'] is String) {
      parsedDate = DateTime.tryParse(data['releaseDate']);
    }

    return MovieModel(
      movieId: doc.id,
      title: data['title'] ?? '',
      originalTitle: data['originalTitle'],
      shortDescription: data['shortDescription'] ?? '',
      longDescription: data['description'] ?? data['longDescription'] ?? '',
      movieVideoId: data['movieVideoId'],
      moviePlaybackUrl: data['moviePlaybackUrl'],
      trailerVideoId: data['trailerVideoId'],
      trailerPlaybackUrl: data['trailerPlaybackUrl'],
      thumbnailUrl: data['thumbnailUrl'],
      posterUrl: data['posterUrl'] ?? '',
      bannerUrl: data['bannerUrl'] ?? '',
      logoUrl: data['logoUrl'],
      categoryId: data['categoryId'] ?? (data['categoryIds'] is List ? (data['categoryIds'] as List).first : ''),
      genreIds: List<String>.from(data['genreIds'] ?? []),
      genreNames: List<String>.from(data['genreNames'] ?? []),
      language: data['language'] ?? 'en',
      availableLanguages: List<String>.from(data['availableLanguages'] ?? []),
      subtitleLanguages: List<String>.from(data['subtitleLanguages'] ?? []),
      duration: data['duration'] ?? 0,
      releaseDate: parsedDate,
      releaseYear: data['releaseYear'] ?? (parsedDate?.year ?? 0),
      ageRating: data['ageRating'] ?? '',
      imdbRating: (data['imdbRating'] ?? 0.0).toDouble(),
      userRating: (data['userRating'] as num?)?.toDouble(),
      cast: (data['cast'] as List<dynamic>?)
              ?.map((e) => CastMemberModel.fromMap(Map<String, dynamic>.from(e)))
              .toList() ?? const [],
      crew: data['crew'] != null ? Map<String, String>.from(data['crew'] is List ? {} : data['crew']) : null,
      director: data['director'] ?? '',
      producer: data['producer'],
      writer: data['writer'],
      musicDirector: data['musicDirector'],
      studio: data['studio'],
      country: data['country'],
      status: data['status'] ?? 'published',
      isFeatured: data['isFeatured'] ?? false,
      isTrending: data['isTrending'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.id,
    required super.name,
    required super.character,
    super.profileUrl,
  });

  factory CastMemberModel.fromMap(Map<String, dynamic> map) {
    return CastMemberModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      character: map['role']?.toString() ?? map['character']?.toString() ?? '',
      profileUrl: map['profileUrl']?.toString(),
    );
  }
}
