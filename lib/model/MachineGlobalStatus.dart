class MachineStatusModel {
  final int totalMachines;
  final int predictedFaults;
  final int nearEndOfLife;

  MachineStatusModel({
    required this.totalMachines,
    required this.predictedFaults,
    required this.nearEndOfLife,
  });

  // Exemple de données mockées
  static MachineStatusModel mockData() {
    return MachineStatusModel(
      totalMachines: 10,
      predictedFaults: 2,
      nearEndOfLife: 3,
    );
  }

  Map<String, double> toPieChartData() {
    return {
      "En activité": (totalMachines - predictedFaults - nearEndOfLife).toDouble(),
      "À surveiller": nearEndOfLife.toDouble(),
      "Critique": predictedFaults.toDouble(),
    };
  }
}
