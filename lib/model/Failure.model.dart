import 'package:json_annotation/json_annotation.dart';

part 'Failure.model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none, includeIfNull: false) // includeIfNull: false is key!
class Failure {
  final int? id; // Nullable
  final DateTime? createdAt; // Nullable
  final bool? isActive; // Nullable
  final DateTime? updatedAt; // Nullable
  final double downtimeHours;
  final String faultType;
  final int machineId;

  Failure({
    this.id, // Not required
    this.createdAt, // Not required
    this.isActive, // Not required
    this.updatedAt, // Not required
    required this.downtimeHours,
    required this.faultType,
    required this.machineId,
  });

  factory Failure.fromJson(Map<String, dynamic> json) => _$FailureFromJson(json);
  Map<String, dynamic> toJson() => _$FailureToJson(this);
}