// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Maintenance.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Maintenance _$MaintenanceFromJson(Map<String, dynamic> json) => Maintenance(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  isActive: json['is_active'] as bool,
  actionDate: DateTime.parse(json['action_date'] as String),
  actionDescription: json['action_description'] as String?,
  cost: (json['cost'] as num).toDouble(),
  isPreventive: json['is_preventive'] as bool,
  machineId: (json['machine_id'] as num).toInt(),
);

Map<String, dynamic> _$MaintenanceToJson(Maintenance instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'is_active': instance.isActive,
      'action_date': instance.actionDate.toIso8601String(),
      'action_description': instance.actionDescription,
      'cost': instance.cost,
      'is_preventive': instance.isPreventive,
      'machine_id': instance.machineId,
    };
