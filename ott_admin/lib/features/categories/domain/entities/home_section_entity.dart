import 'package:equatable/equatable.dart';

enum HomeSectionType { slider, grid, list, banner }

enum HomeSectionQuery { 
  featured, 
  trending, 
  latest, 
  popular, 
  topRated, 
  continueWatching, 
  recommended, 
  recentlyAdded, 
  editorsChoice, 
  custom 
}

class HomeSectionEntity extends Equatable {
  final String id;
  final String title;
  final HomeSectionType type;
  final int displayOrder;
  final bool isEnabled;
  final HomeSectionQuery queryType;
  final String? customQueryId; 
  final DateTime createdAt;
  final DateTime updatedAt;

  const HomeSectionEntity({
    required this.id,
    required this.title,
    required this.type,
    this.displayOrder = 0,
    this.isEnabled = true,
    required this.queryType,
    this.customQueryId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, type, displayOrder, isEnabled, queryType];

  HomeSectionEntity copyWith({
    String? id,
    String? title,
    HomeSectionType? type,
    int? displayOrder,
    bool? isEnabled,
    HomeSectionQuery? queryType,
    String? customQueryId,
    DateTime? updatedAt,
  }) {
    return HomeSectionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      displayOrder: displayOrder ?? this.displayOrder,
      isEnabled: isEnabled ?? this.isEnabled,
      queryType: queryType ?? this.queryType,
      customQueryId: customQueryId ?? this.customQueryId,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
