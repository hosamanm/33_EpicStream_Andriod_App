import 'package:equatable/equatable.dart';

class NotificationSettingsEntity extends Equatable {
  final String userId;
  final bool notificationsEnabled;
  final bool marketingEnabled;
  final List<String> genrePreferences;
  final List<String> languagePreferences;

  const NotificationSettingsEntity({
    required this.userId,
    this.notificationsEnabled = true,
    this.marketingEnabled = true,
    this.genrePreferences = const [],
    this.languagePreferences = const ['en'],
  });

  @override
  List<Object?> get props => [userId, notificationsEnabled, marketingEnabled, genrePreferences, languagePreferences];

  NotificationSettingsEntity copyWith({
    bool? notificationsEnabled,
    bool? marketingEnabled,
    List<String>? genrePreferences,
    List<String>? languagePreferences,
  }) {
    return NotificationSettingsEntity(
      userId: userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
      genrePreferences: genrePreferences ?? this.genrePreferences,
      languagePreferences: languagePreferences ?? this.languagePreferences,
    );
  }
}
