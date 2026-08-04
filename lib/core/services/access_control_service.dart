import '../../features/profile/domain/entities/user_profile_entity.dart';
import '../../features/movies/domain/entities/movie_entity.dart';

/// Business logic service for evaluating content access rights.
/// All content is currently available to all registered users.
class AccessControlService {
  
  /// Determines if a user has sufficient permissions to watch a specific movie.
  bool canUserAccessContent({
    required UserProfileEntity user,
    required MovieEntity movie,
  }) {
    // 1. Every authenticated user has full access to the library.
    // 2. Admin bypass is maintained for future-proofing restricted administrative content.
    if (user.isAdmin) return true;

    return true;
  }
}
