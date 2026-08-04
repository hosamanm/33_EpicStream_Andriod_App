import 'package:flutter/material.dart';
import 'horizontal_movie_list.dart';
import 'section_header.dart';
import 'loading_section.dart';
import 'empty_section.dart';
import 'movie_card.dart';

/// The primary orchestrator for Home screen content rows.
/// It handles the state-based rendering (Loading, Empty, Data) 
/// for specific content categories like "Trending" or "Action".
class MovieSectionWidget extends StatelessWidget {
  final String title;
  final List<MovieCardModel>? items;
  final bool isLoading;
  final SectionLayout layout;
  final VoidCallback? onSeeAll;
  final void Function(MovieCardModel) onMovieTap;

  const MovieSectionWidget({
    super.key,
    required this.title,
    this.items,
    this.isLoading = false,
    this.layout = SectionLayout.portrait,
    this.onSeeAll,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Show Shimmer if loading
    if (isLoading) {
      return LoadingSection(
        isLandscape: layout == SectionLayout.landscape || layout == SectionLayout.large,
      );
    }

    // 2. Show Empty state if no data
    if (items == null || items!.isEmpty) {
      return EmptySection(title: title);
    }

    // 3. Show Content Section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          onSeeAll: onSeeAll,
        ),
        HorizontalMovieList(
          items: items!,
          layout: layout,
          onMovieTap: onMovieTap,
        ),
        const SizedBox(height: 16), // Bottom padding for spacing between sections
      ],
    );
  }
}
