import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../domain/entities/platform_analytics_entity.dart';

class CategoryPieChart extends StatelessWidget {
  final List<CategoryPerformance> categories;
  const CategoryPieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    final colors = [AdminColors.primary, Colors.blueAccent, Colors.orangeAccent, Colors.purpleAccent];

    return PieChart(
      PieChartData(
        sectionsSpace: 4,
        centerSpaceRadius: 40,
        sections: categories.asMap().entries.map((e) {
          final color = colors[e.key % colors.length];
          return PieChartSectionData(
            color: color,
            value: e.value.viewPercentage,
            title: '${e.value.viewPercentage.toInt()}%',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}

class ContentViewsBarChart extends StatelessWidget {
  final List<ContentMetric> metrics;
  const ContentViewsBarChart({super.key, required this.metrics});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: metrics.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.views.toDouble(),
                color: AdminColors.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
