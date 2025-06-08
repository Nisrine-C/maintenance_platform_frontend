import 'package:flutter/material.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';

import '../../constants/colors.dart';
import '../../model/Failure.model.dart';
import '../../model/Machine.model.dart';
import '../../model/Prediction.model.dart';
import '../../widget/machines/machine_item.widget.dart';
import '../../widget/machines/status_indicator.widget.dart';

class MachinesScreen extends StatelessWidget {
  MachinesScreen({Key? key}) : super(key: key);

  final machines = [
    Machine(
      id: 1,
      createdAt: DateTime.parse("2023-01-15"),
      isActive: true,
      updatedAt: DateTime.now(),
      expectedLifetimeHours: 15000,
      name: "Industrial Press",
      serialNumber: "GA12345",
    ),
    Machine(
      id: 2,
      createdAt: DateTime.parse("2022-11-03"),
      isActive: true,
      updatedAt: DateTime.now(),
      expectedLifetimeHours: 12000,
      name: "3D printer",
      serialNumber: "GB12345",
    ),
    Machine(
      id: 3,
      createdAt: DateTime.parse("2023-06-10"),
      isActive: true,
      updatedAt: DateTime.now(),
      expectedLifetimeHours: 13000,
      name: "Industrial press",
      serialNumber: "GC12345",
    ),
  ];

  final failures = [
    Failure(
      id: 1,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      downtimeHours: 0,
      faultType: "No fault",
      machineId: 1,
    ),
    Failure(
      id: 2,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      downtimeHours: 5,
      faultType: "Missing tooth",
      machineId: 2,
    ),
    Failure(
      id: 3,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      downtimeHours: 10,
      faultType: "Chipped tooth",
      machineId: 3,
    ),
  ];

  final predictions = [
    Prediction(
      id: 1,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      confidence: 0.99,
      faultType: "No fault",
      predictedRULHours: 9000.0,
      machineId: 1,
    ),
    Prediction(
      id: 2,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      confidence: 0.85,
      faultType: "Missing tooth",
      predictedRULHours: 800.0,
      machineId: 2,
    ),
    Prediction(
      id: 3,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      confidence: 0.78,
      faultType: "Chipped tooth",
      predictedRULHours: 500.0,
      machineId: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusIndicator(
                  label: 'OK',
                  icon: Icons.check_circle,
                  backgroundColor: tdGreen,
                  iconColor: textGreen,
                  textColor: textGreen,
                ),
                StatusIndicator(
                  label: 'Warning',
                  icon: Icons.error,
                  backgroundColor: tdYellow,
                  iconColor: textYellow,
                  textColor: textYellow,
                ),
                StatusIndicator(
                  label: 'Failure',
                  icon: Icons.cancel,
                  backgroundColor: tdRed,
                  iconColor: textRed,
                  textColor: textRed,
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 5),
                children: machines.map((machine) {
                  final failure = failures.firstWhere((f) => f.machineId == machine.id);
                  final prediction = predictions.firstWhere((p) => p.machineId == machine.id);
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

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgIcon(
            size: 25,
            icon: SvgIconData('assets/svg/menu_icon.svg'),
          ),
          const Text('Machines'),
          Container(
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
