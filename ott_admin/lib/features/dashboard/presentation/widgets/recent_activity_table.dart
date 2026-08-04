import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/admin_colors.dart';
import '../../../movies/domain/entities/admin_movie_entity.dart';

class RecentActivityTable extends StatelessWidget {
  final List<AdminMovieEntity> movies;

  const RecentActivityTable({super.key, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recently Uploaded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AdminColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DataTable(
            horizontalMargin: 24,
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Title')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Date')),
            ],
            rows: movies.take(5).map((movie) {
              return DataRow(cells: [
                DataCell(Text(movie.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(_StatusChip(status: movie.status)),
                DataCell(Text(DateFormat('MMM dd, yyyy').format(movie.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 12))),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AdminMovieStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    if (status == AdminMovieStatus.published) color = Colors.green;
    if (status == AdminMovieStatus.draft) color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
