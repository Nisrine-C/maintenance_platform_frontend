class Maintenance {
  final int id;
  final DateTime createdAt;
  final DateTime scheduledDate;
  final String status; // 'scheduled', 'completed', 'cancelled'
  final String type;
  final String description;
  final int machineId;
  final String technician;
  final double duration; // in hours
  final List<String> tasks;
  final double cost;

  Maintenance({
    required this.id,
    required this.createdAt,
    required this.scheduledDate,
    required this.status,
    required this.type,
    required this.description,
    required this.machineId,
    required this.technician,
    required this.duration,
    required this.tasks,
    required this.cost,
  });

  // Mock data generator
  static List<Maintenance> getMockMaintenanceList() {
    return [
      Maintenance(
        id: 1,
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        scheduledDate: DateTime.now().subtract(Duration(days: 25)),
        status: 'completed',
        type: 'Preventive',
        description: 'Regular inspection and parts replacement',
        machineId: 1,
        technician: 'John Doe',
        duration: 4.5,
        tasks: ['Inspection', 'Oil Change', 'Parts Replacement'],
        cost: 1200.0,
      ),
      Maintenance(
        id: 2,
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        scheduledDate: DateTime.now().add(Duration(days: 5)),
        status: 'scheduled',
        type: 'Corrective',
        description: 'Emergency repair due to bearing failure',
        machineId: 2,
        technician: 'Jane Smith',
        duration: 8.0,
        tasks: ['Bearing Replacement', 'Alignment Check'],
        cost: 2500.0,
      ),
    ];
  }
}
