import 'package:equatable/equatable.dart';

class AgeRatingEntity extends Equatable {
  final String id;
  final String rating; // e.g., 'U', 'U/A 7+'
  final String? description;
  final String? iconUrl;
  final int displayOrder;

  const AgeRatingEntity({
    required this.id,
    required this.rating,
    this.description,
    this.iconUrl,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [id, rating, displayOrder];

  AgeRatingEntity copyWith({
    String? id,
    String? rating,
    String? description,
    String? iconUrl,
    int? displayOrder,
  }) {
    return AgeRatingEntity(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
