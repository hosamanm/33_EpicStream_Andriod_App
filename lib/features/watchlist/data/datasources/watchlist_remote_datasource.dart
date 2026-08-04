import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../movies/data/models/movie_model.dart';

abstract class WatchlistRemoteDataSource {
  Future<void> addToWatchlist(String movieId);
  Future<void> removeFromWatchlist(String movieId);
  Future<bool> isInWatchlist(String movieId);
  Future<List<MovieModel>> getWatchlist();
  Stream<List<String>> watchWatchlistIds();
}

class WatchlistRemoteDataSourceImpl implements WatchlistRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  WatchlistRemoteDataSourceImpl(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  DocumentReference? get _userDoc {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }
  
  CollectionReference? get _watchlistCol => _userDoc?.collection('watchlist');

  @override
  Future<void> addToWatchlist(String movieId) async {
    final col = _watchlistCol;
    if (col == null) throw Exception('User not authenticated');
    await col.doc(movieId).set({
      'movieId': movieId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFromWatchlist(String movieId) async {
    final col = _watchlistCol;
    if (col == null) throw Exception('User not authenticated');
    await col.doc(movieId).delete();
  }

  @override
  Future<bool> isInWatchlist(String movieId) async {
    final col = _watchlistCol;
    if (col == null) return false;
    final doc = await col.doc(movieId).get();
    return doc.exists;
  }

  @override
  Future<List<MovieModel>> getWatchlist() async {
    final col = _watchlistCol;
    if (col == null) return [];
    
    final snapshot = await col.orderBy('addedAt', descending: true).get();
    final movieIds = snapshot.docs.map((doc) => doc.id).toList();

    if (movieIds.isEmpty) return [];

    final movieSnapshots = await _firestore
        .collection('movies')
        .where(FieldPath.documentId, whereIn: movieIds)
        .get();

    final movieMap = {for (var doc in movieSnapshots.docs) doc.id: MovieModel.fromFirestore(doc)};
    return movieIds.map((id) => movieMap[id]).whereType<MovieModel>().toList();
  }

  @override
  Stream<List<String>> watchWatchlistIds() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value([]);
      return _firestore.collection('users').doc(user.uid)
          .collection('watchlist')
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
    });
  }
}
