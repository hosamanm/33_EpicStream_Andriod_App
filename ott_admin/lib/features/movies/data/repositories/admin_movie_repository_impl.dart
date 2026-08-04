import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../../domain/repositories/admin_movie_repository.dart';
import '../models/admin_movie_model.dart';
import '../services/admin_movie_service.dart';
import '../../../activity_logs/domain/repositories/activity_log_repository.dart';
import '../../../activity_logs/domain/entities/activity_log_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminMovieRepositoryImpl implements AdminMovieRepository {
  final AdminMovieService _service;
  final ActivityLogRepository _logRepository;
  final FirebaseAuth _auth;

  AdminMovieRepositoryImpl(this._service, this._logRepository, this._auth);

  String get _adminEmail => _auth.currentUser?.email ?? 'system';
  String get _adminId => _auth.currentUser?.uid ?? 'system';

  @override
  Future<Result<List<AdminMovieEntity>>> getMovies({int limit = 20, AdminMovieEntity? lastMovie}) async {
    try {
      final models = await _service.fetchMovies(limit: limit);
      return Result.success(models);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> addMovie(AdminMovieEntity movie) async {
    try {
      final model = AdminMovieModel(
        id: '',
        title: movie.title,
        originalTitle: movie.originalTitle,
        description: movie.description,
        shortDescription: movie.shortDescription,
        posterUrl: movie.posterUrl,
        bannerUrl: movie.bannerUrl,
        logoUrl: movie.logoUrl,
        thumbnailUrl: movie.thumbnailUrl,
        trailerVideoId: movie.trailerVideoId,
        trailerPlaybackUrl: movie.trailerPlaybackUrl,
        movieVideoId: movie.movieVideoId,
        moviePlaybackUrl: movie.moviePlaybackUrl,
        subtitleUrls: movie.subtitleUrls,
        audioTracks: movie.audioTracks,
        genreIds: movie.genreIds,
        categoryIds: movie.categoryIds,
        language: movie.language,
        country: movie.country,
        cast: movie.cast,
        crew: movie.crew,
        director: movie.director,
        producer: movie.producer,
        writer: movie.writer,
        musicDirector: movie.musicDirector,
        duration: movie.duration,
        releaseDate: movie.releaseDate,
        ageRating: movie.ageRating,
        imdbRating: movie.imdbRating,
        status: movie.status,
        isFeatured: movie.isFeatured,
        isTrending: movie.isTrending,
        isEditorsChoice: movie.isEditorsChoice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final movieDoc = await _service.saveMovie(model);
      
      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: ActivityAction.upload,
        module: ActivityModule.movies,
        targetId: movieDoc ?? movie.title,
        description: 'Uploaded new movie: ${movie.title}',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateMovie(AdminMovieEntity movie) async {
    try {
      final model = AdminMovieModel(
        id: movie.id,
        title: movie.title,
        originalTitle: movie.originalTitle,
        description: movie.description,
        shortDescription: movie.shortDescription,
        posterUrl: movie.posterUrl,
        bannerUrl: movie.bannerUrl,
        logoUrl: movie.logoUrl,
        thumbnailUrl: movie.thumbnailUrl,
        trailerVideoId: movie.trailerVideoId,
        trailerPlaybackUrl: movie.trailerPlaybackUrl,
        movieVideoId: movie.movieVideoId,
        moviePlaybackUrl: movie.moviePlaybackUrl,
        subtitleUrls: movie.subtitleUrls,
        audioTracks: movie.audioTracks,
        genreIds: movie.genreIds,
        categoryIds: movie.categoryIds,
        language: movie.language,
        country: movie.country,
        cast: movie.cast,
        crew: movie.crew,
        director: movie.director,
        producer: movie.producer,
        writer: movie.writer,
        musicDirector: movie.musicDirector,
        duration: movie.duration,
        releaseDate: movie.releaseDate,
        ageRating: movie.ageRating,
        imdbRating: movie.imdbRating,
        status: movie.status,
        isFeatured: movie.isFeatured,
        isTrending: movie.isTrending,
        isEditorsChoice: movie.isEditorsChoice,
        createdAt: movie.createdAt,
        updatedAt: DateTime.now(),
      );
      await _service.saveMovie(model);

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: ActivityAction.edit,
        module: ActivityModule.movies,
        targetId: movie.id,
        description: 'Updated movie details: ${movie.title}',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMovie(String id) async {
    try {
      await _service.deleteMovie(id as AdminMovieModel);

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: ActivityAction.delete,
        module: ActivityModule.movies,
        targetId: id,
        description: 'Deleted movie ID: $id',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> togglePublish(String id, bool publish) async {
    try {
      await _service.updateMovieStatus(id, publish ? AdminMovieStatus.published.name : AdminMovieStatus.draft.name);

      await _logRepository.logAction(ActivityLogEntity(
        id: '',
        adminId: _adminId,
        adminEmail: _adminEmail,
        action: publish ? ActivityAction.publish : ActivityAction.unpublish,
        module: ActivityModule.movies,
        targetId: id,
        description: '${publish ? 'Published' : 'Unpublished'} movie ID: $id',
        ipAddress: '0.0.0.0',
        timestamp: DateTime.now(),
      ));

      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
