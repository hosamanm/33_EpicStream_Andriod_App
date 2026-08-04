import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String id;
  final String name;
  final String code; // ISO 3166-1 alpha-2
  final String? flagUrl;
  final int displayOrder;
  final bool isEnabled;

  const CountryEntity({
    required this.id,
    required this.name,
    required this.code,
    this.flagUrl,
    this.displayOrder = 0,
    this.isEnabled = true,
  });

  @override
  List<Object?> get props => [id, name, code, displayOrder, isEnabled];

  CountryEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? flagUrl,
    int? displayOrder,
    bool? isEnabled,
  }) {
    return CountryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      flagUrl: flagUrl ?? this.flagUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
