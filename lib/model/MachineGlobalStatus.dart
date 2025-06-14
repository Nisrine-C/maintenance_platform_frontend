class MachineStatusModel {
   final int total;
  final int predictedFaults;
  final int nearEndOfLife;
  final int active;
 

  MachineStatusModel({
   required this.total,
    required this.predictedFaults,
    required this.nearEndOfLife,
    required this.active,
  });

  

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
      
    );
  }
}
