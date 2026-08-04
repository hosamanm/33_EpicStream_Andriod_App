import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/country_entity.dart';

class CountryModel extends CountryEntity {
  const CountryModel({
    required super.id,
    required super.name,
    required super.code,
    super.flagUrl,
    super.displayOrder,
    super.isEnabled,
  });

  factory CountryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CountryModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      flagUrl: data['flagUrl'],
      displayOrder: data['displayOrder'] ?? 0,
      isEnabled: data['isEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'flagUrl': flagUrl,
      'displayOrder': displayOrder,
      'isEnabled': isEnabled,
    };
  }
}
