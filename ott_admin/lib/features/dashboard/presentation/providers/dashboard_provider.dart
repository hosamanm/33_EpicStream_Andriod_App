import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../../users/domain/entities/admin_user_entity.dart';
import '../../../movies/domain/entities/admin_movie_entity.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardProvider(this._repository);

  DashboardStatus _status = DashboardStatus.initial;
  DashboardStatus get status => _status;

  DashboardStats? _stats;
  DashboardStats? get stats => _stats;

  List<int> _userGrowthData = [];
  List<int> get userGrowthData => _userGrowthData;

  List<AdminUserEntity> _recentUsers = [];
  List<AdminUserEntity> get recentUsers => _recentUsers;

  List<AdminMovieEntity> _recentMovies = [];
  List<AdminMovieEntity> get recentMovies => _recentMovies;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
    _status = DashboardStatus.loading;
    notifyListeners();

    try {
      final statsResult = await _repository.getPlatformStats();
      final growthResult = await _repository.getMonthlyUserGrowth();
      
      // These would be new methods in the repository
      final recentUsersResult = await _repository.getRecentUsers(limit: 5);
      final recentMoviesResult = await _repository.getRecentMovies(limit: 5);

      if (statsResult.isSuccess && growthResult.isSuccess) {
        _stats = statsResult.data;
        _userGrowthData = growthResult.data;
        _recentUsers = recentUsersResult.isSuccess ? recentUsersResult.data! : [];
        _recentMovies = recentMoviesResult.isSuccess ? recentMoviesResult.data! : [];
        _status = DashboardStatus.loaded;
      } else {
        _errorMessage = statsResult.isError ? statsResult.failure.message : "Failed to load dashboard data";
        _status = DashboardStatus.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = DashboardStatus.error;
    }
    notifyListeners();
  }
}
