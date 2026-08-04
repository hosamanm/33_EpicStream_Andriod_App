import 'package:equatable/equatable.dart';

/// Production-grade User Profile Entity.
class UserProfileEntity extends Equatable {
  final String uid;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  
  // Roles & Status
  final String role; // 'user', 'admin', 'moderator'
  final String status; // 'active', 'suspended'
  
  // Localization & Region
  final String language;
  final String? country;
  
  // Preferences (Aligned with Firestore Schema Requirements)
  final List<String> favoriteGenres;
  final String themeMode; // 'light', 'dark', 'system'
  final bool notificationEnabled;
  final bool subtitleEnabled;
  final String audioLanguage;
  
  // Legacy/Internal Preferences
  final bool watchHistoryEnabled;
  final bool downloadEnabled;
  
  // Auth & System
  final bool isGuest;
  final bool isEmailVerified;
  final String? fcmToken;
  final Map<String, dynamic>? deviceInfo;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;

  const UserProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.role = 'user',
    this.status = 'active',
    this.language = 'en',
    this.country,
    required this.favoriteGenres,
    this.themeMode = 'dark',
    this.notificationEnabled = true,
    this.subtitleEnabled = true,
    this.audioLanguage = 'en',
    this.watchHistoryEnabled = true,
    this.downloadEnabled = true,
    this.isGuest = false,
    this.isEmailVerified = false,
    this.fcmToken,
    this.deviceInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
  });

  /// Helper getter to check if the user has administrative privileges.
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [uid, email, role, isGuest];

  UserProfileEntity copyWith({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
    String? role,
    String? status,
    String? language,
    String? country,
    List<String>? favoriteGenres,
    String? themeMode,
    bool? notificationEnabled,
    bool? subtitleEnabled,
    String? audioLanguage,
    bool? watchHistoryEnabled,
    bool? downloadEnabled,
    bool? isEmailVerified,
    String? fcmToken,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return UserProfileEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      language: language ?? this.language,
      country: country ?? this.country,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      themeMode: themeMode ?? this.themeMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      subtitleEnabled: subtitleEnabled ?? this.subtitleEnabled,
      audioLanguage: audioLanguage ?? this.audioLanguage,
      watchHistoryEnabled: watchHistoryEnabled ?? this.watchHistoryEnabled,
      downloadEnabled: downloadEnabled ?? this.downloadEnabled,
      isGuest: isGuest,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceInfo: deviceInfo,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
