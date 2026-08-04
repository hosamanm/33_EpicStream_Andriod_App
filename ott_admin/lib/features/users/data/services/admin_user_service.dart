import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user_model.dart';

class AdminUserService {
  final FirebaseFirestore _firestore;

  AdminUserService(this._firestore);

  /// Fetches users with pagination support.
  Future<QuerySnapshot> fetchUsersSnapshot({int limit = 20, DocumentSnapshot? startAfter}) async {
    Query query = _firestore.collection('users').orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return await query.get();
  }

  /// Fetches a user's library and history for management inspection.
  Future<Map<String, dynamic>> getUserLibrary(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    
    // Using parallel fetches for performance across all library modules
    final results = await Future.wait([
      userRef.collection('watchlist').get(),
      userRef.collection('favorites').get(),
      userRef.collection('watch_history').orderBy('updatedAt', descending: true).limit(20).get(),
      userRef.collection('downloads').get(),
    ]);

    return {
      'watchlist': results[0].docs.map((d) => d.data()).toList(),
      'favorites': results[1].docs.map((d) => d.data()).toList(),
      'history': results[2].docs.map((d) => d.data()).toList(),
      'downloads': results[3].docs.map((d) => d.data()).toList(),
    };
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteUser(String uid) async {
    // Note: This only deletes the Firestore document. 
    // Sub-collections and Auth user should be handled by a Cloud Function trigger or admin SDK.
    await _firestore.collection('users').doc(uid).delete();
  }
}
