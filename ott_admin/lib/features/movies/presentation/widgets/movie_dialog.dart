import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../domain/entities/admin_movie_entity.dart';
import 'movie_form.dart';

class MovieDialog extends StatelessWidget {
  final AdminMovieEntity? movie;
  final Function({
    required AdminMovieEntity movie,
    Uint8List? poster,
    Uint8List? banner,
    Uint8List? logo,
    Uint8List? thumbnail,
    Uint8List? video,
    Uint8List? trailer,
    List<Uint8List>? subtitles,
  }) onSave;

  const MovieDialog({super.key, this.movie, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Container(
        width: 1000,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    movie == null ? 'Add New OTT Content' : 'Edit Content Metadata',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Expanded(
              child: MovieForm(
                movie: movie,
                onSave: (data) => onSave(
                  movie: data['movie'],
                  poster: data['poster'],
                  banner: data['banner'],
                  logo: data['logo'],
                  thumbnail: data['thumbnail'],
                  video: data['video'],
                  trailer: data['trailer'],
                  subtitles: data['subtitles'],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
