import 'package:json_annotation/json_annotation.dart';

part 'Machine.model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class Machine {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double expectedLifetimeHours;
  final String name;
  final String serialNumber;

  Machine({
    required this.id,
    required this.createdAt,
    required this.isActive,
    required this.updatedAt,
    required this.expectedLifetimeHours,
    required this.name,
    required this.serialNumber,
  });

  factory Machine.fromJson(Map<String, dynamic> json) => _$MachineFromJson(json);
  Map<String, dynamic> toJson() => _$MachineToJson(this);

}
