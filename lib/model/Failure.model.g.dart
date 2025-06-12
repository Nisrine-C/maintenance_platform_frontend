// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Failure.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Failure _$FailureFromJson(Map<String, dynamic> json) => Failure(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  downtimeHours: (json['downtimeHours'] as num).toDouble(),
  faultType: json['faultType'] as String,
  machineId: (json['machineId'] as num).toInt(),
);

Map<String, dynamic> _$FailureToJson(Failure instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
  'updatedAt': instance.updatedAt.toIso8601String(),
  'downtimeHours': instance.downtimeHours,
  'faultType': instance.faultType,
  'machineId': instance.machineId,
};
