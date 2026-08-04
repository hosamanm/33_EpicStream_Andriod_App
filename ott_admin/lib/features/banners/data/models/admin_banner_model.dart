import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/admin_banner_entity.dart';

class AdminBannerModel extends AdminBannerEntity {
  const AdminBannerModel({
    required super.id,
    required super.title,
    super.description,
    required super.mobileImageUrl,
    required super.tabletImageUrl,
    required super.desktopImageUrl,
    required super.type,
    required super.status,
    required super.targetType,
    required super.targetValue,
    required super.startDate,
    required super.endDate,
    required super.priority,
  });

  factory AdminBannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminBannerModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      mobileImageUrl: data['mobileImageUrl'] ?? '',
      tabletImageUrl: data['tabletImageUrl'] ?? '',
      desktopImageUrl: data['desktopImageUrl'] ?? '',
      type: BannerType.values.firstWhere((e) => e.name == (data['type'] ?? 'home')),
      status: BannerStatus.values.firstWhere((e) => e.name == (data['status'] ?? 'draft')),
      targetType: BannerTargetType.values.firstWhere((e) => e.name == (data['targetType'] ?? 'movie')),
      targetValue: data['targetValue'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      priority: data['priority'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'mobileImageUrl': mobileImageUrl,
      'tabletImageUrl': tabletImageUrl,
      'desktopImageUrl': desktopImageUrl,
      'type': type.name,
      'status': status.name,
      'targetType': targetType.name,
      'targetValue': targetValue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'priority': priority,
    };
  }
}
