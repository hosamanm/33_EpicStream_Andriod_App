import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_settings_entity.dart';

class NotificationSettingsModel extends NotificationSettingsEntity {
  const NotificationSettingsModel({
    required super.userId,
    super.notificationsEnabled = true,
    super.marketingEnabled = true,
    super.genrePreferences = const [],
    super.languagePreferences = const ['en'],
  });

  factory NotificationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationSettingsModel(
      userId: doc.id,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      marketingEnabled: data['marketingEnabled'] ?? true,
      genrePreferences: List<String>.from(data['genrePreferences'] ?? []),
      languagePreferences: List<String>.from(data['languagePreferences'] ?? ['en']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'marketingEnabled': marketingEnabled,
      'genrePreferences': genrePreferences,
      'languagePreferences': languagePreferences,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
