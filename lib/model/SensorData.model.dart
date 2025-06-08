class SensorData {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double loadValue;
  final double speedSet;
  final double vibrationX;
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
}
