import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/vibration_histogram.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/VibrationTrendChart.dart';

class GraphSection extends StatelessWidget {
  final int machineId;

  const GraphSection({super.key, required this.machineId});

  @override

Widget build(BuildContext context) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      minHeight: MediaQuery.of(context).size.height * 0.6,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( // Constrain histogram
          height: 400,
          child: VibrationHistogram(machineId: machineId),
        ),
        const SizedBox(height: 24),
        SizedBox( // Constrain trend chart
          height: 300,
          child: VibrationTrendChart(machineId: machineId),
        ),
      ],
    ),
  );
}
}
