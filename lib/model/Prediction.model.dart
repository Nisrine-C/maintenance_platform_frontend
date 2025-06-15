
import 'package:json_annotation/json_annotation.dart';

part 'Prediction.model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class Prediction {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double confidence;
  final String faultType;
  @JsonKey(defaultValue: 0.0)
  final double predictedRULHours;
  final int machineId;

  Prediction({
    required this.id,
    required this.createdAt,
    required this.isActive,
    required this.updatedAt,
    required this.confidence,
    required this.faultType,
    required this.predictedRULHours,
    required this.machineId,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => _$PredictionFromJson(json);
  Map<String, dynamic> toJson() => _$PredictionToJson(this);

}
