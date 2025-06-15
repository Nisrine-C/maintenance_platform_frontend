// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'SensorData.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorData _$SensorDataFromJson(Map<String, dynamic> json) => SensorData(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  loadValue: (json['loadValue'] as num?)?.toDouble() ?? 0.0,
  speedSet: (json['speedSet'] as num?)?.toDouble() ?? 0.0,
  vibrationX: (json['vibrationX'] as num?)?.toDouble() ?? 0.0,
  vibrationY: (json['vibrationY'] as num?)?.toDouble() ?? 0.0,
  machineId: (json['machineId'] as num).toInt(),
);

Map<String, dynamic> _$SensorDataToJson(SensorData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'loadValue': instance.loadValue,
      'speedSet': instance.speedSet,
      'vibrationX': instance.vibrationX,
      'vibrationY': instance.vibrationY,
      'machineId': instance.machineId,
    };
