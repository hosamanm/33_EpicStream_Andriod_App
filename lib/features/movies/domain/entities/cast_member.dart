import 'package:equatable/equatable.dart';

/// Production-grade entity for Cast and Crew members.
class CastMember extends Equatable {
  final String id;
  final String name;
  final String character;
  final String? profileUrl;
  final String? biography;
  final List<String> knownFor; // List of Movie IDs

  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profileUrl,
    this.biography,
    this.knownFor = const [],
  });

  @override
  List<Object?> get props => [id, name, character, profileUrl, biography, knownFor];
}
