
import 'package:json_annotation/json_annotation.dart';

part 'SensorData.model.g.dart';

@JsonSerializable(fieldRename:FieldRename.none)
class SensorData {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  @JsonKey(defaultValue: 0.0)
  final double loadValue;
  @JsonKey(defaultValue: 0.0)
  final double speedSet;
  @JsonKey(defaultValue: 0.0)
  final double vibrationX;
  @JsonKey(defaultValue: 0.0)
  final double vibrationY;
  final int machineId;

  SensorData({
    required this.id,
    required this.createdAt,
    required this.isActive,
    required this.updatedAt,
    required this.loadValue,
    required this.speedSet,
    required this.vibrationX,
    required this.vibrationY,
    required this.machineId,
  });
  factory SensorData.fromJson(Map<String, dynamic> json) => _$SensorDataFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataToJson(this);

}
