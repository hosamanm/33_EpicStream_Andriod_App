import 'package:flutter/material.dart';
import '../../domain/entities/activity_log_entity.dart';
import '../../domain/repositories/activity_log_repository.dart';

enum ActivityLogStatus { initial, loading, loaded, error }

class ActivityLogProvider extends ChangeNotifier {
  final ActivityLogRepository _repository;

  ActivityLogProvider(this._repository);

  ActivityLogStatus _status = ActivityLogStatus.initial;
  ActivityLogStatus get status => _status;

  List<ActivityLogEntity> _logs = [];
  List<ActivityLogEntity> get logs => _logs;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ActivityModule? _filterModule;
  ActivityAction? _filterAction;
  DateTimeRange? _filterDateRange;

  ActivityModule? get filterModule => _filterModule;
  ActivityAction? get filterAction => _filterAction;
  DateTimeRange? get filterDateRange => _filterDateRange;

  Future<void> fetchLogs({bool refresh = false}) async {
    if (_status == ActivityLogStatus.loading && !refresh) return;

    _status = ActivityLogStatus.loading;
    notifyListeners();

    final result = await _repository.getLogs(
      module: _filterModule,
      action: _filterAction,
      startDate: _filterDateRange?.start,
      endDate: _filterDateRange?.end,
    );

    result.fold(
      (failure) {
        _status = ActivityLogStatus.error;
        _errorMessage = failure.message;
      },
      (logs) {
        _status = ActivityLogStatus.loaded;
        _logs = logs;
      },
    );
    notifyListeners();
  }

  void setFilters({
    ActivityModule? module,
    ActivityAction? action,
    DateTimeRange? dateRange,
  }) {
    _filterModule = module;
    _filterAction = action;
    _filterDateRange = dateRange;
    fetchLogs(refresh: true);
  }

  void clearFilters() {
    _filterModule = null;
    _filterAction = null;
    _filterDateRange = null;
    fetchLogs(refresh: true);
  }
}
