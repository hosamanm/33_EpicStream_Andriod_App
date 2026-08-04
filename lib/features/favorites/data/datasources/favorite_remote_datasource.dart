import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<void> addFavorite(String userId, FavoriteModel favorite);
  Future<void> removeFavorite(String userId, String id);
  Stream<List<FavoriteModel>> watchFavorites(String userId, {String? type});
  Future<bool> isFavorite(String userId, String id);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final FirebaseFirestore _firestore;

  FavoriteRemoteDataSourceImpl(this._firestore);

  CollectionReference _favoritesCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('favorites');

  @override
  Future<void> addFavorite(String userId, FavoriteModel favorite) async {
    await _favoritesCollection(userId).doc(favorite.id).set(favorite.toFirestore());
  }

  @override
  Future<void> removeFavorite(String userId, String id) async {
    await _favoritesCollection(userId).doc(id).delete();
  }

  @override
  Stream<List<FavoriteModel>> watchFavorites(String userId, {String? type}) {
    Query query = _favoritesCollection(userId).orderBy('favoritedAt', descending: true);
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList());
  }

  @override
  Future<bool> isFavorite(String userId, String id) async {
    final doc = await _favoritesCollection(userId).doc(id).get();
    return doc.exists;
  }
}
