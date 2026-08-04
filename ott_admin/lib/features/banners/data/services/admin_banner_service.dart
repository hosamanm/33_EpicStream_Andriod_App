import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_banner_model.dart';
import '../../domain/entities/admin_banner_entity.dart';

class AdminBannerService {
  final FirebaseFirestore _firestore;

  AdminBannerService(this._firestore);

  Future<List<AdminBannerModel>> fetchBanners({BannerType? type}) async {
    Query query = _firestore.collection('banners').orderBy('priority');
    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AdminBannerModel.fromFirestore(doc)).toList();
  }

  Future<void> saveBanner(AdminBannerModel banner) async {
    if (banner.id.isEmpty) {
      await _firestore.collection('banners').add(banner.toFirestore());
    } else {
      await _firestore.collection('banners').doc(banner.id).set(banner.toFirestore(), SetOptions(merge: true));
    }
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection('banners').doc(id).delete();
  }

  Future<void> updatePriorities(List<String> ids) async {
    final batch = _firestore.batch();
    for (int i = 0; i < ids.length; i++) {
      batch.update(_firestore.collection('banners').doc(ids[i]), {'priority': i});
    }
    await batch.commit();
  }
}
