import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile_model.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel?> getUserProfile(String uid);
  Future<void> createUserProfile(UserProfileModel profile);
  Future<void> updateUserProfile(UserProfileModel profile);
  Future<void> deleteUserProfile(String uid);
  Stream<UserProfileModel?> watchUserProfile(String uid);
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'users';

  UserProfileRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> createUserProfile(UserProfileModel profile) async {
    await _firestore.collection(_collection).doc(profile.uid).set(profile.toFirestore());
  }

  @override
  Future<UserProfileModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromFirestore(doc);
  }

  @override
  Future<void> updateUserProfile(UserProfileModel profile) async {
    await _firestore.collection(_collection).doc(profile.uid).update(profile.toFirestore());
  }

  @override
  Future<void> deleteUserProfile(String uid) async {
    await _firestore.collection(_collection).doc(uid).delete();
  }

  @override
  Stream<UserProfileModel?> watchUserProfile(String uid) {
    return _firestore
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfileModel.fromFirestore(doc) : null);
  }
}
