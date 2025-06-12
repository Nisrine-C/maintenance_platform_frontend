class Failure {
  final int id;
  final String faultType;
  final double downtimeHours;
  final DateTime createdAt;
  final String machineName;

  Failure({
    required this.id,
    required this.faultType,
    required this.downtimeHours,
    required this.createdAt,
    required this.machineName,
  });

  factory Failure.fromJson(Map<String, dynamic> json) {
    return Failure(
      id: json['id'],
      faultType: json['faultType'],
      downtimeHours: (json['downtimeHours'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      machineName: json['machine']['name'],
    );
  }
}
