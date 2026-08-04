import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/favorite_entity.dart';

class FavoriteModel extends FavoriteEntity {
  final String userId;

  const FavoriteModel({
    required super.id,
    required super.title,
    required super.posterUrl,
    required super.type,
    required super.favoritedAt,
    required this.userId,
  });

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      posterUrl: data['posterUrl'] ?? '',
      type: data['type'] ?? 'movie',
      favoritedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory FavoriteModel.fromEntity(FavoriteEntity entity, String userId) {
    return FavoriteModel(
      id: entity.id,
      title: entity.title,
      posterUrl: entity.posterUrl,
      type: entity.type,
      favoritedAt: entity.favoritedAt,
      userId: userId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': id,
      'title': title,
      'posterUrl': posterUrl,
      'type': type,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }
}
