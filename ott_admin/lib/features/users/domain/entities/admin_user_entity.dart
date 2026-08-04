import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String? phone;
  final String? profileImage;
  final bool isBlocked;
  final bool isEmailVerified;
  final bool isGuest;
  final int watchTimeMinutes;
  final int deviceCount;
  final int downloadCount;
  final DateTime createdAt;
  final DateTime lastLogin;

  const AdminUserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phone,
    this.profileImage,
    required this.isBlocked,
    required this.isEmailVerified,
    required this.isGuest,
    required this.watchTimeMinutes,
    required this.deviceCount,
    required this.downloadCount,
    required this.createdAt,
    required this.lastLogin,
  });

  @override
  List<Object?> get props => [uid, email, isBlocked, isEmailVerified];

  AdminUserEntity copyWith({
    bool? isBlocked,
    bool? isEmailVerified,
  }) {
    return AdminUserEntity(
      uid: uid,
      fullName: fullName,
      email: email,
      phone: phone,
      profileImage: profileImage,
      isBlocked: isBlocked ?? this.isBlocked,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isGuest: isGuest,
      watchTimeMinutes: watchTimeMinutes,
      deviceCount: deviceCount,
      downloadCount: downloadCount,
      createdAt: createdAt,
      lastLogin: lastLogin,
    );
  }
}
