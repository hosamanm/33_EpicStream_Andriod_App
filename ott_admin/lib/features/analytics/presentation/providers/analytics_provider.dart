import 'package:flutter/material.dart';
import '../../domain/entities/platform_analytics_entity.dart';
import '../../domain/repositories/analytics_repository.dart';

enum AnalyticsStatus { initial, loading, loaded, error }

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsProvider(this._repository);

  AnalyticsStatus _status = AnalyticsStatus.initial;
  AnalyticsStatus get status => _status;

  PlatformAnalyticsEntity? _analytics;
  PlatformAnalyticsEntity? get analytics => _analytics;

  List<int> _userActivityData = [];
  List<int> get userActivityData => _userActivityData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  DateTimeRange get dateRange => _dateRange;

  Future<void> fetchAnalytics() async {
    _status = AnalyticsStatus.loading;
    notifyListeners();

    final result = await _repository.getPlatformAnalytics(
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );
    final activityResult = await _repository.getUserActivityData();

    if (result.isSuccess && activityResult.isSuccess) {
      _analytics = result.data;
      _userActivityData = activityResult.data;
      _status = AnalyticsStatus.loaded;
    } else {
      _errorMessage = result.isError ? result.failure.message : 'Failed to load analytics';
      _status = AnalyticsStatus.error;
    }
    notifyListeners();
  }

  void updateDateRange(DateTimeRange newRange) {
    _dateRange = newRange;
    fetchAnalytics();
  }
}
