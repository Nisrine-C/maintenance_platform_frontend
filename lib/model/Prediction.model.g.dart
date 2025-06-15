// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Prediction.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prediction _$PredictionFromJson(Map<String, dynamic> json) => Prediction(
  id: (json['id'] as num?)?.toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  confidence: (json['confidence'] as num).toDouble(),
  faultType: json['faultType'] as String,
  predictedRULHours: (json['predictedRULHours'] as num?)?.toDouble() ?? 0.0,
  machineId: (json['machineId'] as num).toInt(),
);

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'confidence': instance.confidence,
      'faultType': instance.faultType,
      'predictedRULHours': instance.predictedRULHours,
      'machineId': instance.machineId,
    };
