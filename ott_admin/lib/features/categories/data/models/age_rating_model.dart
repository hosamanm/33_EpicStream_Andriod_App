import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/age_rating_entity.dart';

class AgeRatingModel extends AgeRatingEntity {
  const AgeRatingModel({
    required super.id,
    required super.rating,
    super.description,
    super.iconUrl,
    super.displayOrder,
  });

  factory AgeRatingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AgeRatingModel(
      id: doc.id,
      rating: data['rating'] ?? '',
      description: data['description'],
      iconUrl: data['iconUrl'],
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'rating': rating,
      'description': description,
      'iconUrl': iconUrl,
      'displayOrder': displayOrder,
    };
  }
}
