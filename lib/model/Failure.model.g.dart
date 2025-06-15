// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Failure.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Failure _$FailureFromJson(Map<String, dynamic> json) => Failure(
  id: (json['id'] as num?)?.toInt(),
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool?,
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  downtimeHours: (json['downtimeHours'] as num).toDouble(),
  faultType: json['faultType'] as String,
  machineId: (json['machineId'] as num).toInt(),
);

Map<String, dynamic> _$FailureToJson(Failure instance) => <String, dynamic>{
  if (instance.id case final value?) 'id': value,
  if (instance.createdAt?.toIso8601String() case final value?)
    'createdAt': value,
  if (instance.isActive case final value?) 'isActive': value,
  if (instance.updatedAt?.toIso8601String() case final value?)
    'updatedAt': value,
  'downtimeHours': instance.downtimeHours,
  'faultType': instance.faultType,
  'machineId': instance.machineId,
};
