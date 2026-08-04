import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/language_entity.dart';

class LanguageModel extends LanguageEntity {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.code,
    super.iconUrl,
    super.isDefault,
    super.isEnabled,
    super.displayOrder,
  });

  factory LanguageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LanguageModel(
      id: doc.id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      iconUrl: data['iconUrl'] ?? data['flagIcon'], // Map flagIcon to iconUrl if it exists in Firestore
      isDefault: data['isDefault'] ?? false,
      isEnabled: data['isEnabled'] ?? true,
      displayOrder: data['displayOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'code': code,
      'iconUrl': iconUrl,
      'isDefault': isDefault,
      'isEnabled': isEnabled,
      'displayOrder': displayOrder,
    };
  }
}
