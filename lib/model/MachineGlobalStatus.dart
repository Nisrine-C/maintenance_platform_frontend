class MachineStatusModel {
   final int total;
  final int predictedFaults;
  final int nearEndOfLife;
  final int active;
  final int tets ;

  MachineStatusModel({
   required this.total,
    required this.predictedFaults,
    required this.nearEndOfLife,
    required this.active,
    required this.tets,
  });

  // Exemple de données mockées
  static MachineStatusModel mockData() {
    return MachineStatusModel(
      total: 10,
      predictedFaults: 2,
      nearEndOfLife: 3,
      active: 12,
      tets: 1,
    );
  }

  Map<String, double> toPieChartData() {
    return {
      "En activité": (total - predictedFaults - nearEndOfLife).toDouble(),
      "À surveiller": nearEndOfLife.toDouble(),
      "Critique": predictedFaults.toDouble(),
    };
  }

   factory MachineStatusModel.fromJson(Map<String, dynamic> json) {
    return MachineStatusModel(
      total: json['total'],
      predictedFaults: json['predictedFaults'],
      nearEndOfLife: json['nearEndOfLife'],
      active: json['active'],
      tets: json['tets'],
    );
  }
}
