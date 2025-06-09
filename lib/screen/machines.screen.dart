import 'package:flutter/material.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';

// Import the AI Engine Service
import '../services/ai_engine_service.dart';

// Your other project imports
import '../constants/colors.dart';
import '../model/Failure.model.dart';
import '../model/Machine.model.dart';
import '../model/Prediction.model.dart';
import '../widget/machine_item.widget.dart';
import '../widget/status_indicator.widget.dart';

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({Key? key}) : super(key: key);

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  // AI Engine Service instance
  final AiEngineService _aiEngine = AiEngineService();

  // Your hard-coded data for UI display purposes
  final List<Machine> machines = [
    Machine(id: 1, createdAt: DateTime.parse("2023-01-15"), isActive: true, updatedAt: DateTime.now(), expectedLifetimeHours: 15000, name: "Industrial Press", serialNumber: "GA12345"),
    Machine(id: 2, createdAt: DateTime.parse("2022-11-03"), isActive: true, updatedAt: DateTime.now(), expectedLifetimeHours: 12000, name: "3D printer", serialNumber: "GB12345"),
    Machine(id: 3, createdAt: DateTime.parse("2023-06-10"), isActive: true, updatedAt: DateTime.now(), expectedLifetimeHours: 13000, name: "Industrial press", serialNumber: "GC12345"),
  ];

  final List<Failure> failures = [
    Failure(id: 1, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), downtimeHours: 0, faultType: "No fault", machineId: 1),
    Failure(id: 2, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), downtimeHours: 5, faultType: "Missing tooth", machineId: 2),
    Failure(id: 3, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), downtimeHours: 10, faultType: "Chipped tooth", machineId: 3),
  ];

  final List<Prediction> predictions = [
    Prediction(id: 1, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), confidence: 0.99, faultType: "No fault", predictedRULHours: 9000.0, machineId: 1),
    Prediction(id: 2, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), confidence: 0.85, faultType: "Missing tooth", predictedRULHours: 800.0, machineId: 2),
    Prediction(id: 3, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(), confidence: 0.78, faultType: "Chipped tooth", predictedRULHours: 500.0, machineId: 3),
  ];

  @override
  void initState() {
    super.initState();
    // Start the AI engine when this screen is first built.
    // It will run in the background and save predictions to a file.
    _aiEngine.initializeAndRun();
    print("MachinesScreen: AI Engine has been started.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            // Status indicators row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusIndicator(label: 'OK', icon: Icons.check_circle, backgroundColor: tdGreen, iconColor: textGreen, textColor: textGreen),
                StatusIndicator(label: 'Warning', icon: Icons.error, backgroundColor: tdYellow, iconColor: textYellow, textColor: textYellow),
                StatusIndicator(label: 'Failure', icon: Icons.cancel, backgroundColor: tdRed, iconColor: textRed, textColor: textRed),
              ],
            ),
            // List of machines
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 5),
                children: machines.map((machine) {
                  // Find the corresponding failure and prediction for the current machine
                  final failure = failures.firstWhere(
                        (f) => f.machineId == machine.id,
                    // Provide a default 'Failure' object in case no match is found
                    orElse: () => Failure(id: -1, createdAt: DateTime.now(), isActive: false, updatedAt: DateTime.now(), downtimeHours: 0, faultType: "N/A", machineId: machine.id),
                  );
                  final prediction = predictions.firstWhere(
                        (p) => p.machineId == machine.id,
                    // Provide a default 'Prediction' object in case no match is found
                    orElse: () => Prediction(id: -1, createdAt: DateTime.now(), isActive: false, updatedAt: DateTime.now(), confidence: 0, faultType: "N/A", predictedRULHours: 0, machineId: machine.id),
                  );

                  return MachineItem(
                    machine: machine,
                    failure: failure,
                    prediction: prediction,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Your custom AppBar widget builder
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SvgIcon(
            size: 25,
            icon: SvgIconData('assets/svg/menu_icon.svg'),
          ),
          const Text('Machines'),
          SizedBox(
            height: 40,
            width: 40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/img/avatar.png'),
            ),
          ),
        ],
      ),
    );
  }
}