import 'package:flutter/material.dart';

import '../../appBar/appBar.dart';
import '../../constants/colors.dart';
import '../../model/Failure.model.dart';
import '../../model/Machine.model.dart';
import '../../model/Prediction.model.dart';
import '../../services/machine_service.dart';
import '../../widget/machines/machine_item.widget.dart';
import '../../widget/machines/status_indicator.widget.dart';
import 'machine_detail.screen.dart';



class MachinesScreen extends StatefulWidget {
  MachinesScreen({Key? key}) : super(key: key);

  @override
  State<MachinesScreen> createState()=> _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final MachineService _machineService = MachineService();
  late Future<List<Machine>> _machinesFuture;

  final List<Failure> failures = [
    Failure(id: 1,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        downtimeHours: 0,
        faultType: "No fault",
        machineId: 1),
    Failure(id: 2,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        downtimeHours: 5,
        faultType: "Missing tooth",
        machineId: 2),
    Failure(id: 3,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        downtimeHours: 10,
        faultType: "Chipped tooth",
        machineId: 3),
  ];
  final List<Prediction> predictions = [
    Prediction(id: 1,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        confidence: 0.99,
        faultType: "No fault",
        predictedRULHours: 9000.0,
        machineId: 1),
    Prediction(id: 2,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        confidence: 0.85,
        faultType: "Missing tooth",
        predictedRULHours: 800.0,
        machineId: 2),
    Prediction(id: 3,
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        confidence: 0.78,
        faultType: "Chipped tooth",
        predictedRULHours: 500.0,
        machineId: 3),
  ];

  @override
  void initState() {
    super.initState();
    _machinesFuture = _machineService.getMachines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Machines')),
      drawer: buildHomeDrawer(context),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusIndicator(label: 'OK', icon: Icons.check_circle, backgroundColor: tdGreen, iconColor: textGreen, textColor: textGreen),
                StatusIndicator(label: 'Warning', icon: Icons.error, backgroundColor: tdYellow, iconColor: textYellow, textColor: textYellow),
                StatusIndicator(label: 'Failure', icon: Icons.cancel, backgroundColor: tdRed, iconColor: textRed, textColor: textRed),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<Machine>>(
                future: _machinesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No machines found.'));
                  }

                  final liveMachines = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: liveMachines.length,
                    itemBuilder: (context, index) {
                      final machine = liveMachines[index];

                      final failure = failures.firstWhere((f) => f.machineId == machine.id, orElse: () => Failure(id: -1, createdAt: DateTime.now(), isActive: false, updatedAt: DateTime.now(), downtimeHours: 0, faultType: "N/A", machineId: machine.id),
                      );
                      final prediction = predictions.firstWhere((p) => p.machineId == machine.id, orElse: () => Prediction(id: -1, createdAt: DateTime.now(), isActive: false, updatedAt: DateTime.now(), confidence: 0, faultType: "N/A", predictedRULHours: 0, machineId: machine.id),);


                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detail(machine: machine),
                            ),
                          );
                        },
                        child: MachineItem(
                          machine: machine,
                          failure: failure,
                          prediction: prediction,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}