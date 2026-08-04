import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    super.phone,
    super.profileImage,
    required super.isBlocked,
    required super.isEmailVerified,
    required super.isGuest,
    required super.watchTimeMinutes,
    required super.deviceCount,
    required super.downloadCount,
    required super.createdAt,
    required super.lastLogin,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      uid: doc.id,
      fullName: data['fullName'] ?? data['displayName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? data['phoneNumber'],
      profileImage: data['profileImage'] ?? data['photoUrl'],
      isBlocked: data['isBlocked'] ?? (data['status'] == 'blocked'),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isGuest: data['isGuest'] ?? false,
      watchTimeMinutes: data['watchTimeMinutes'] ?? 0,
      deviceCount: data['deviceCount'] ?? 0,
      downloadCount: data['downloadCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'isBlocked': isBlocked,
      'isEmailVerified': isEmailVerified,
      'isGuest': isGuest,
      'watchTimeMinutes': watchTimeMinutes,
      'deviceCount': deviceCount,
      'downloadCount': downloadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'status': isBlocked ? 'blocked' : 'active',
    };
  }
}
