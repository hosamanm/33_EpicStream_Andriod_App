import 'package:equatable/equatable.dart';

class GenreEntity extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final int displayOrder;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GenreEntity({
    required this.id,
    required this.name,
    this.imageUrl,
    this.displayOrder = 0,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, displayOrder, isEnabled];

  GenreEntity copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? displayOrder,
    bool? isEnabled,
    DateTime? updatedAt,
  }) {
    return GenreEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
