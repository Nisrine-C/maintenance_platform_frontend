import 'package:json_annotation/json_annotation.dart';

part 'Maintenance.model.g.dart';

// Use snake_case to automatically convert from database names like 'created_at' to Dart names like 'createdAt'
@JsonSerializable(fieldRename: FieldRename.snake)
class Maintenance {
  final int id;

  // These fields exist in the database
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final DateTime actionDate;

  // Make description nullable as it might be empty
  final String? actionDescription;

  final double cost;
  final bool isPreventive;
  final int machineId;

  Maintenance({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.actionDate,
    this.actionDescription, // Now optional
    required this.cost,
    required this.isPreventive,
    required this.machineId,
  });

  factory Maintenance.fromJson(Map<String, dynamic> json) => _$MaintenanceFromJson(json);
  Map<String, dynamic> toJson() => _$MaintenanceToJson(this);


  static List<Maintenance> getMockMaintenanceList() {
    return [
      // ... old mock data ...
    ];
  }

}