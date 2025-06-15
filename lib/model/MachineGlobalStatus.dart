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
    final sum = total + predictedFaults + nearEndOfLife;

    if (sum == 0) {
      return {
        'En activité': 0,
        'À surveiller': 0,
        'Critique': 0,
      };
    }

    return {
      'En activité': (total / sum) * 100,
      'À surveiller': (nearEndOfLife / sum) * 100,
      'Critique': (predictedFaults / sum) * 100,
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
