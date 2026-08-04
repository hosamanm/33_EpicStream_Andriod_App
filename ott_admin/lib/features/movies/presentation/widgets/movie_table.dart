import 'package:flutter/material.dart';
import '../../domain/entities/admin_movie_entity.dart';
import '../controllers/movie_management_controller.dart';
import '../../../../core/theme/admin_colors.dart';

class MovieTable extends StatefulWidget {
  final List<AdminMovieEntity> movies;
  final MovieManagementController controller;

  const MovieTable({
    super.key,
    required this.movies,
    required this.controller,
  });

  @override
  State<MovieTable> createState() => _MovieTableState();
}

class _MovieTableState extends State<MovieTable> {
  final Set<String> _selectedIds = {};

  void _toggleSelection(String? id) {
    setState(() {
      if (id == null) {
        if (_selectedIds.length == widget.movies.length) {
          _selectedIds.clear();
        } else {
          _selectedIds.addAll(widget.movies.map((e) => e.id));
        }
      } else {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
        } else {
          _selectedIds.add(id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: AdminColors.primary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Text('${_selectedIds.length} items selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => widget.controller.onBulkPublish(context, _selectedIds.toList(), true),
                  icon: const Icon(Icons.publish, size: 18),
                  label: const Text('PUBLISH'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => widget.controller.onBulkPublish(context, _selectedIds.toList(), false),
                  icon: const Icon(Icons.unpublished, size: 18),
                  label: const Text('UNPUBLISH'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () => widget.controller.onBulkDelete(context, _selectedIds.toList()),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.redAccent),
                  label: const Text('DELETE', style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        DataTable(
          columnSpacing: 24,
          headingRowColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.05)),
          showCheckboxColumn: true,
          columns: [
            DataColumn(
              label: Checkbox(
                value: _selectedIds.length == widget.movies.length && widget.movies.isNotEmpty,
                onChanged: (_) => _toggleSelection(null),
              ),
            ),
            const DataColumn(label: Text('Movie', style: TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: Text('Added On', style: TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: widget.movies.map((movie) {
            final isSelected = _selectedIds.contains(movie.id);
            return DataRow(
              selected: isSelected,
              onSelectChanged: (_) => _toggleSelection(movie.id),
              cells: [
                DataCell(Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(movie.id),
                )),
                DataCell(Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(movie.posterUrl, width: 40, height: 60, fit: BoxFit.cover, 
                        errorBuilder: (_, __, ___) => Container(width: 40, height: 60, color: Colors.grey[800], child: const Icon(Icons.movie, size: 20))),
                    ),
                    const SizedBox(width: 12),
                    Text(movie.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )),
                DataCell(_StatusBadge(status: movie.status)),
                DataCell(Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(movie.imdbRating.toString()),
                  ],
                )),
                DataCell(Text(movie.createdAt.toString().split(' ')[0])),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueAccent),
                      onPressed: () => widget.controller.onEditMovie(context, movie),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => widget.controller.onDeleteMovie(context, movie.id),
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AdminMovieStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case AdminMovieStatus.published:
        color = Colors.greenAccent;
        break;
      case AdminMovieStatus.draft:
        color = Colors.orangeAccent;
        break;
      case AdminMovieStatus.archived:
        color = Colors.grey;
        break;
      case AdminMovieStatus.scheduled:
        color = Colors.blueAccent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
