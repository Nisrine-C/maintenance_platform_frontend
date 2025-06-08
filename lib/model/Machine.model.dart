class Machine {
  final int id;
  final DateTime createdAt;
  final bool isActive;
  final DateTime updatedAt;
  final double expectedLifetimeHours;
  final String name;
  final String serialNumber;

  Machine({
    required this.id,
    required this.createdAt,
    required this.isActive,
    required this.updatedAt,
    required this.expectedLifetimeHours,
    required this.name,
    required this.serialNumber,
  });
}
