import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    super.role = 'user',
    super.status = 'active',
    super.language = 'en',
    super.country,
    required super.favoriteGenres,
    super.themeMode = 'dark',
    super.notificationEnabled = true,
    super.subtitleEnabled = true,
    super.audioLanguage = 'en',
    super.watchHistoryEnabled = true,
    super.downloadEnabled = true,
    super.isGuest = false,
    super.isEmailVerified = false,
    super.fcmToken,
    super.deviceInfo,
    required super.createdAt,
    required super.updatedAt,
    required super.lastLogin,
  });

  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfileModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      role: data['role'] ?? 'user',
      status: data['status'] ?? 'active',
      language: data['language'] ?? 'en',
      country: data['country'],
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      themeMode: data['themeMode'] ?? 'dark',
      notificationEnabled: data['notificationEnabled'] ?? true,
      subtitleEnabled: data['subtitleEnabled'] ?? true,
      audioLanguage: data['audioLanguage'] ?? 'en',
      watchHistoryEnabled: data['watchHistoryEnabled'] ?? true,
      downloadEnabled: data['downloadEnabled'] ?? true,
      isGuest: data['isGuest'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
      fcmToken: data['fcmToken'],
      deviceInfo: data['deviceInfo'] != null 
          ? Map<String, dynamic>.from(data['deviceInfo']) 
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role,
      'status': status,
      'language': language,
      'country': country,
      'favoriteGenres': favoriteGenres,
      'themeMode': themeMode,
      'notificationEnabled': notificationEnabled,
      'subtitleEnabled': subtitleEnabled,
      'audioLanguage': audioLanguage,
      'watchHistoryEnabled': watchHistoryEnabled,
      'downloadEnabled': downloadEnabled,
      'isGuest': isGuest,
      'isEmailVerified': isEmailVerified,
      'fcmToken': fcmToken,
      'deviceInfo': deviceInfo,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }
}
