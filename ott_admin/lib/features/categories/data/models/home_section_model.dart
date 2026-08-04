import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/home_section_entity.dart';

class HomeSectionModel extends HomeSectionEntity {
  const HomeSectionModel({
    required super.id,
    required super.title,
    required super.type,
    super.displayOrder,
    super.isEnabled,
    required super.queryType,
    super.customQueryId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory HomeSectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HomeSectionModel(
      id: doc.id,
      title: data['title'] ?? '',
      type: HomeSectionType.values.firstWhere(
        (e) => e.name == (data['type'] ?? 'grid'),
        orElse: () => HomeSectionType.grid,
      ),
      displayOrder: data['displayOrder'] ?? 0,
      isEnabled: data['enabled'] ?? true,
      queryType: HomeSectionQuery.values.firstWhere(
        (e) => e.name == (data['queryType'] ?? 'latest'),
        orElse: () => HomeSectionQuery.latest,
      ),
      customQueryId: data['customQueryId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'type': type.name,
      'displayOrder': displayOrder,
      'enabled': isEnabled,
      'queryType': queryType.name,
      'customQueryId': customQueryId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
