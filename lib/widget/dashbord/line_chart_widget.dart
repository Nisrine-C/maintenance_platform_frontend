import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maintenance_platform_frontend/model/DailySensorStats.dart';

class LineChartWidget extends StatelessWidget {
  final List<DailySensorStats> stats;

  const LineChartWidget({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: stats.asMap().entries.map((entry) {
                final index = entry.key;
                final stat = entry.value;
                return FlSpot(index.toDouble(), stat.average);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index >= 0 && index < stats.length) {
                    final date = stats[index].date;
                    return Text("${date.month}/${date.day}", style: TextStyle(fontSize: 10));
                  }
                  return Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
        ),
      ),
    );
  }
}
