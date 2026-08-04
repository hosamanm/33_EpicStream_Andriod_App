import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_log_model.dart';

class ActivityLogService {
  final FirebaseFirestore _firestore;
  static const String _collection = 'admin_audit_logs';

  ActivityLogService(this._firestore);

  Future<void> recordLog(ActivityLogModel log) async {
    await _firestore.collection(_collection).add(log.toFirestore());
  }

  Future<List<ActivityLogModel>> fetchLogs({
    int limit = 50,
    String? module,
    String? action,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (module != null) {
      query = query.where('module', isEqualTo: module);
    }
    if (action != null) {
      query = query.where('action', isEqualTo: action);
    }
    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => ActivityLogModel.fromFirestore(doc)).toList();
  }
}
