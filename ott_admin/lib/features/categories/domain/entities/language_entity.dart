import 'package:equatable/equatable.dart';

class LanguageEntity extends Equatable {
  final String id;
  final String name;
  final String code; // e.g., 'en', 'es'
  final String? iconUrl;
  final bool isDefault;
  final bool isEnabled;
  final int displayOrder;

  const LanguageEntity({
    required this.id,
    required this.name,
    required this.code,
    this.iconUrl,
    this.isDefault = false,
    this.isEnabled = true,
    this.displayOrder = 0,
  });

  @override
  List<Object?> get props => [id, name, code, isDefault, isEnabled, displayOrder];

  LanguageEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? iconUrl,
    bool? isDefault,
    bool? isEnabled,
    int? displayOrder,
  }) {
    return LanguageEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      iconUrl: iconUrl ?? this.iconUrl,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
