class Prediction {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double confidence;
  final String faultType;
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
}
