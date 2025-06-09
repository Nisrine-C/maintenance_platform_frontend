import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/model/DailySensorStats.dart';

import 'line_chart_widget.dart';
import 'bar_chart_widget.dart';

class GraphSection extends StatelessWidget {
  const GraphSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DailySensorStats> sampleStats = List.generate(7, (i) {
      return DailySensorStats(
        date: DateTime.now().subtract(Duration(days: 6 - i)),
        average: 10 + i.toDouble() + (i % 2 == 0 ? 2 : -1),
        min: 8 + i.toDouble(),
        max: 12 + i.toDouble(),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Évolution Moyenne (vibrations)", style: Theme.of(context).textTheme.titleMedium),
        LineChartWidget(stats: sampleStats),
        const SizedBox(height: 16),
        Text("Histogramme Exemple", style: Theme.of(context).textTheme.titleMedium),
        const BarChartWidget(),
      ],
    );
  }
}
