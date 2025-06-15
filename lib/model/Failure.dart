class Failure {
  final int id;
  final bool isActive;
  final int machineId;
  final double downtimeHours;
  final String faultType;
  final String machineName;
  final DateTime createdAt;

  Failure({
    required this.id,
    required this.isActive,
    required this.machineId,
    required this.downtimeHours,
    required this.faultType,
    required this.machineName,
    required this.createdAt,
  });

  factory Failure.fromJson(Map<String, dynamic> json) {
    return Failure(
      id: json['id'],
      isActive: json['isActive'],
      machineId: json['machineId'],
      downtimeHours: (json['downtimeHours'] as num).toDouble(),
      faultType: json['faultType'],
      machineName: json['machineName'] ?? "Industrial Press", // ← doit être envoyé par le backend
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
