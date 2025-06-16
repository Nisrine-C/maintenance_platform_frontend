// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Machine.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Machine _$MachineFromJson(Map<String, dynamic> json) => Machine(
  id: (json['id'] as num?)?.toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  expectedLifetimeHours: (json['expectedLifetimeHours'] as num).toDouble(),
  name: json['name'] as String,
  serialNumber: json['serialNumber'] as String,
);

Map<String, dynamic> _$MachineToJson(Machine instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'isActive': instance.isActive,
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'expectedLifetimeHours': instance.expectedLifetimeHours,
  'name': instance.name,
  'serialNumber': instance.serialNumber,
};
