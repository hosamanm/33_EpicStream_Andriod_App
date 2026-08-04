import 'package:equatable/equatable.dart';

enum BannerType { home, featured, trending, offer, advertisement }
enum BannerStatus { draft, published, archived }
enum BannerTargetType { movie, category, url }

class AdminBannerEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String mobileImageUrl;
  final String tabletImageUrl;
  final String desktopImageUrl;
  final BannerType type;
  final BannerStatus status;
  final BannerTargetType targetType;
  final String targetValue; // Movie ID, Category ID, or URL
  final DateTime startDate;
  final DateTime endDate;
  final int priority;

  const AdminBannerEntity({
    required this.id,
    required this.title,
    this.description,
    required this.mobileImageUrl,
    required this.tabletImageUrl,
    required this.desktopImageUrl,
    required this.type,
    required this.status,
    required this.targetType,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    required this.priority,
  });

  @override
  List<Object?> get props => [id, status, priority, type];

  AdminBannerEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? mobileImageUrl,
    String? tabletImageUrl,
    String? desktopImageUrl,
    BannerType? type,
    BannerStatus? status,
    BannerTargetType? targetType,
    String? targetValue,
    DateTime? startDate,
    DateTime? endDate,
    int? priority,
  }) {
    return AdminBannerEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mobileImageUrl: mobileImageUrl ?? this.mobileImageUrl,
      tabletImageUrl: tabletImageUrl ?? this.tabletImageUrl,
      desktopImageUrl: desktopImageUrl ?? this.desktopImageUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      targetType: targetType ?? this.targetType,
      targetValue: targetValue ?? this.targetValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      priority: priority ?? this.priority,
    );
  }
}
