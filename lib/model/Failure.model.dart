class Failure {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double downtimeHours;
  final String faultType;
  final int machineId;

  Failure({
    required this.id,
    required this.createdAt,
    required this.isActive,
    required this.updatedAt,
    required this.downtimeHours,
    required this.faultType,
    required this.machineId,
  });
}
