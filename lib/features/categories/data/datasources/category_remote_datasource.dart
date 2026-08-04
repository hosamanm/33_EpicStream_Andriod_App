import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/genre_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<GenreModel>> getGenres();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<GenreModel>> getGenres() async {
    final snapshot = await _firestore.collection('genres').get();
    return snapshot.docs.map((doc) => GenreModel.fromFirestore(doc)).toList();
  }
}
