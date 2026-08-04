import 'package:equatable/equatable.dart';
import 'cast_member.dart';

/// Production-grade Movie Entity for EpicStream.
/// Contains comprehensive metadata for cinematic display and streaming.
class MovieEntity extends Equatable {
  final String movieId;
  final String title;
  final String? originalTitle;
  final String shortDescription;
  final String longDescription;
  
  // Cloudflare Stream Integration
  final String? movieVideoId;
  final String? moviePlaybackUrl;
  final String? trailerVideoId;
  final String? trailerPlaybackUrl;
  final String? thumbnailUrl;
  
  final String posterUrl;
  final String bannerUrl;
  final String? logoUrl;
  
  final String categoryId;
  final List<String> genreIds;
  final List<String> genreNames;
  final String language;
  final List<String> availableLanguages;
  final List<String> subtitleLanguages;
  
  final int duration; 
  final DateTime? releaseDate;
  final int releaseYear;
  final String ageRating;
  final double imdbRating;
  final double? userRating;
  
  // Cast & Crew
  final List<CastMember> cast;
  final String director;
  final String? producer;
  final String? writer;
  final String? musicDirector;
  final String? studio;
  final String? country;
  final Map<String, String>? crew;
  final String? awards;
  
  // Status & Flags
  final String status;
  final bool isFeatured;
  final bool isTrending;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  const MovieEntity({
    required this.movieId,
    required this.title,
    this.originalTitle,
    required this.shortDescription,
    required this.longDescription,
    this.movieVideoId,
    this.moviePlaybackUrl,
    this.trailerVideoId,
    this.trailerPlaybackUrl,
    this.thumbnailUrl,
    required this.posterUrl,
    required this.bannerUrl,
    this.logoUrl,
    required this.categoryId,
    required this.genreIds,
    required this.genreNames,
    required this.language,
    required this.availableLanguages,
    required this.subtitleLanguages,
    required this.duration,
    this.releaseDate,
    required this.releaseYear,
    required this.ageRating,
    required this.imdbRating,
    this.userRating,
    required this.cast,
    required this.director,
    this.producer,
    this.writer,
    this.musicDirector,
    this.studio,
    this.country,
    this.crew,
    this.awards,
    this.status = 'published',
    this.isFeatured = false,
    this.isTrending = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [movieId, movieVideoId, title];
}
