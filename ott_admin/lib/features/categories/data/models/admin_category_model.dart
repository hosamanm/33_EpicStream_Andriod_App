import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_category_entity.dart';

class AdminCategoryModel extends AdminCategoryEntity {
  const AdminCategoryModel({
    required super.id,
    required super.name,
    required super.description,
    super.imageUrl,
    super.iconUrl,
    super.displayOrder,
    super.isEnabled,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminCategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      iconUrl: data['iconUrl'],
      displayOrder: data['displayOrder'] ?? 0,
      isEnabled: data['isEnabled'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'displayOrder': displayOrder,
      'isEnabled': isEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
