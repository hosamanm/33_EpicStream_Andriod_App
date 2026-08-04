import 'dart:io';
import '../../../../core/services/storage_service.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/user_profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  final UserProfileRepository _repository;
  final FirebaseAuth _auth;
  final StorageService _storageService;

  ProfileService(this._repository, this._auth, this._storageService);

  Stream<UserProfileEntity?> watchProfile() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }
      return _repository.watchUserProfile(user.uid);
    });
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    await _repository.updateUserProfile(profile);
  }

  Future<String> uploadProfilePicture(File file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    
    return await _storageService.uploadFile(
      file: file,
      folder: 'profile_images',
      fileName: uid,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _repository.deleteUserProfile(uid);
      await _auth.currentUser?.delete();
    }
  }
}
