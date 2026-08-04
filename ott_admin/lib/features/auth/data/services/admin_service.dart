import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_entity.dart';

class AdminService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AdminService(this._auth, this._firestore);

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AdminEntity?> getAdminData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return AdminEntity(
      uid: uid,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      role: _parseRole(data['role']),
    );
  }

  AdminRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'superadmin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'editor':
        return AdminRole.editor;
      case 'viewer':
      default:
        return AdminRole.viewer;
    }
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
