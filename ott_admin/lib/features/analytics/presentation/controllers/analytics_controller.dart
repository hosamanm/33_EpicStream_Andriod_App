import 'package:flutter/material.dart';
import '../providers/analytics_provider.dart';
import '../../data/services/report_generator.dart';

/// Controller for the Analytics Dashboard.
/// Handles UI interactions like date filtering and report generation.
class AnalyticsController {
  final AnalyticsProvider _provider;
  final ReportGenerator _reportGenerator;

  AnalyticsController(this._provider, this._reportGenerator);

  Future<void> onDateRangeSelected(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _provider.dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _provider.updateDateRange(picked);
    }
  }

  Future<void> exportReport(String format) async {
    final data = _provider.analytics;
    if (data == null) return;

    switch (format) {
      case 'PDF':
        await _reportGenerator.generatePDF(data);
        break;
      case 'Excel':
        await _reportGenerator.generateExcel(data);
        break;
      case 'CSV':
        await _reportGenerator.generateCSV(data);
        break;
    }
  }

  void refresh() {
    _provider.fetchAnalytics();
  }
}
