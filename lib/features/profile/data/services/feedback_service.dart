import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeedbackService(this._firestore, this._auth);

  Future<void> submitFeedback({
    required String type,
    required String details,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return; // Silent return or handle appropriately in UI

    await _firestore.collection('feedback').add({
      'userId': user.uid,
      'userEmail': user.email,
      'type': type,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
      'appVersion': '1.0.0', 
    });
  }
}
