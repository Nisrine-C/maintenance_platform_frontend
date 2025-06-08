import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final double chartRadius;

  const PieChartWidget({
    Key? key,
    required this.dataMap,
    required this.colorList,
    this.chartRadius = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartRadius: chartRadius,
      colorList: colorList,
      chartType: ChartType.ring,
      ringStrokeWidth: 25,
      legendOptions: LegendOptions(
        showLegends: true,
        legendPosition: LegendPosition.bottom,
        showLegendsInRow: true,
        legendTextStyle: TextStyle(fontSize: 14),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 1,
        chartValueStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
