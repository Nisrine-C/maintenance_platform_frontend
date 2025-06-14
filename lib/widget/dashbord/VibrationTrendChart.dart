import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maintenance_platform_frontend/model/VibrationTrend.dart';
import 'package:maintenance_platform_frontend/services/DashbordService/SensorDataService.dart';

class VibrationTrendChart extends StatefulWidget {
  final int machineId;

  const VibrationTrendChart({super.key, required this.machineId});

  @override
  State<VibrationTrendChart> createState() => _VibrationTrendChartState();
}

class _VibrationTrendChartState extends State<VibrationTrendChart> {
  final SensorService _service = SensorService();
  List<VibrationTrend> _data = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    final trends = await _service.getVibrationTrends(widget.machineId);
    setState(() {
      _data = trends;
    });
  }

  @override
Widget build(BuildContext context) {
  if (_data.isEmpty) return const Center(child: CircularProgressIndicator());

  return SizedBox(
    height: 300,
    child: Stack(
      children: [
        LineChart(
          LineChartData(
            titlesData: FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: _data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.vibrationX))
                    .toList(),
                color: Colors.blue,
                dotData: FlDotData(show: false),
              ),
              LineChartBarData(
                spots: _data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value.vibrationY))
                    .toList(),
                color: Colors.red,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.blue, size: 16),
                SizedBox(width: 4),
                Text('Axe X', style: TextStyle(fontSize: 12)),
                SizedBox(width: 12),
                Icon(Icons.circle, color: Colors.red, size: 16),
                SizedBox(width: 4),
                Text('Axe Y', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}}