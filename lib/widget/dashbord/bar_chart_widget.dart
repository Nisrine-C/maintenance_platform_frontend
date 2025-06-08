import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 5.0 + index,
                  color: Colors.orange,
                  width: 12,
                ),
              ],
            );
          }),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
        ),
      ),
    );
  }
}
