import 'package:equatable/equatable.dart';

class AdminCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String? iconUrl;
  final int displayOrder;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminCategoryEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.iconUrl,
    this.displayOrder = 0,
    this.isEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, displayOrder, isEnabled];

  AdminCategoryEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? iconUrl,
    int? displayOrder,
    bool? isEnabled,
    DateTime? updatedAt,
  }) {
    return AdminCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
