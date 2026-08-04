import 'dart:convert';
import 'dart:html' as html;
import '../../domain/entities/platform_analytics_entity.dart';

class ReportGenerator {
  /// Generates and triggers download of a CSV report.
  Future<void> generateCSV(PlatformAnalyticsEntity data) async {
    final List<List<String>> rows = [
      ['Metric', 'Value'],
      ['Total Users', data.userAnalytics.totalUsers.toString()],
      ['Daily Active Users', data.userAnalytics.dailyActiveUsers.toString()],
      ['Monthly Active Users', data.userAnalytics.monthlyActiveUsers.toString()],
      ['Total Watch Hours', data.watchTimeAnalytics.monthlyWatchTime.toString()],
      ['Bandwidth Usage (TB)', data.bandwidthUsageTB.toString()],
      ['Storage Usage (TB)', data.storageUsageTB.toString()],
      ['Avg Completion Rate', '${(data.contentAnalytics.avgCompletionRate * 100).toStringAsFixed(1)}%'],
      [],
      ['Most Watched Movies', 'Views'],
      ...data.contentAnalytics.mostWatchedMovies.map((m) => [m.title, m.views.toString()]),
    ];

    String csv = const IterableToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'epicstream_report_${DateTime.now().millisecondsSinceEpoch}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  /// Placeholder for Excel generation. 
  /// Usually requires the 'excel' package or server-side generation.
  Future<void> generateExcel(PlatformAnalyticsEntity data) async {
    print('Excel Generation Triggered for Admin Panel');
    // For now, we can fallback to CSV or show a message that this is a premium feature.
  }

  /// In a production web environment, PDF generation often happens server-side 
  /// or via a complex JS interop. For this module, we provide the architecture 
  /// to trigger the Cloud Function or local PDF generation.
  Future<void> generatePDF(PlatformAnalyticsEntity data) async {
    // Implementation would typically use the 'pdf' package or 
    // call a Firebase Cloud Function that uses 'puppeteer' or 'pdfkit'.
    print('PDF Generation Triggered for Admin Panel');
  }
}

/// Simple CSV Converter if the 'csv' package is not available
class IterableToCsvConverter {
  const IterableToCsvConverter();
  String convert(List<List<String>> rows) {
    return rows.map((row) => row.join(',')).join('\n');
  }
}
