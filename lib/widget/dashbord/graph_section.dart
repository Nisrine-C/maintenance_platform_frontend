import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/vibration_histogram.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/VibrationTrendChart.dart';

class GraphSection extends StatelessWidget {
  final int machineId;

  const GraphSection({super.key, required this.machineId});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VibrationHistogram(machineId: machineId),
        const SizedBox(height: 24),
        VibrationTrendChart(machineId: machineId),
      ],
    );
  }
}
