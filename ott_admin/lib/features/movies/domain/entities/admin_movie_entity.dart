import 'package:equatable/equatable.dart';

enum AdminMovieStatus { draft, published, archived, scheduled }

class AdminMovieEntity extends Equatable {
  final String id;
  final String title;
  final String? originalTitle;
  final String description;
  final String shortDescription;
  
  // Media Assets
  final String posterUrl;
  final String bannerUrl;
  final String? logoUrl;
  final String? thumbnailUrl;
  
  // Cloudflare Stream Data
  final String? trailerVideoId;
  final String? trailerPlaybackUrl;
  final String? movieVideoId;
  final String? moviePlaybackUrl;
  
  // Advanced Multi-Track
  final List<String> subtitleUrls;
  final List<Map<String, String>> audioTracks; 
  
  // Taxonomy
  final List<String> genreIds;
  final List<String> genreNames; // Added for App-side sync
  final List<String> categoryIds;
  final String language;
  final String country;
  
  // People & Credits
  final List<Map<String, String>> cast;
  final List<Map<String, String>> crew;
  final String director;
  final String producer;
  final String writer;
  final String musicDirector;
  
  // Platform Flags
  final AdminMovieStatus status;
  final bool isFeatured;
  final bool isTrending;
  final bool isEditorsChoice;
  
  // Metadata
  final int duration;
  final String releaseDate;
  final int releaseYear; // Added for App-side sync
  final String ageRating;
  final double imdbRating;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminMovieEntity({
    required this.id,
    required this.title,
    this.originalTitle,
    required this.description,
    required this.shortDescription,
    required this.posterUrl,
    required this.bannerUrl,
    this.logoUrl,
    this.thumbnailUrl,
    this.trailerVideoId,
    this.trailerPlaybackUrl,
    this.movieVideoId,
    this.moviePlaybackUrl,
    this.subtitleUrls = const [],
    this.audioTracks = const [],
    required this.genreIds,
    this.genreNames = const [],
    required this.categoryIds,
    required this.language,
    required this.country,
    this.cast = const [],
    this.crew = const [],
    required this.director,
    required this.producer,
    required this.writer,
    required this.musicDirector,
    required this.duration,
    required this.releaseDate,
    this.releaseYear = 0,
    required this.ageRating,
    required this.imdbRating,
    this.status = AdminMovieStatus.draft,
    this.isFeatured = false,
    this.isTrending = false,
    this.isEditorsChoice = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, status, movieVideoId, updatedAt];

  AdminMovieEntity copyWith({
    String? id,
    String? title,
    String? originalTitle,
    String? description,
    String? shortDescription,
    String? posterUrl,
    String? bannerUrl,
    String? logoUrl,
    String? thumbnailUrl,
    String? movieVideoId,
    String? moviePlaybackUrl,
    List<String>? genreNames,
    int? releaseYear,
    AdminMovieStatus? status,
    DateTime? updatedAt,
  }) {
    return AdminMovieEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      posterUrl: posterUrl ?? this.posterUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      trailerVideoId: trailerVideoId,
      trailerPlaybackUrl: trailerPlaybackUrl,
      movieVideoId: movieVideoId ?? this.movieVideoId,
      moviePlaybackUrl: moviePlaybackUrl ?? this.moviePlaybackUrl,
      subtitleUrls: subtitleUrls,
      audioTracks: audioTracks,
      genreIds: genreIds,
      genreNames: genreNames ?? this.genreNames,
      categoryIds: categoryIds,
      language: language,
      country: country,
      cast: cast,
      crew: crew,
      director: director,
      producer: producer,
      writer: writer,
      musicDirector: musicDirector,
      duration: duration,
      releaseDate: releaseDate,
      releaseYear: releaseYear ?? this.releaseYear,
      ageRating: ageRating,
      imdbRating: imdbRating,
      status: status ?? this.status,
      isFeatured: isFeatured,
      isTrending: isTrending,
      isEditorsChoice: isEditorsChoice,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
