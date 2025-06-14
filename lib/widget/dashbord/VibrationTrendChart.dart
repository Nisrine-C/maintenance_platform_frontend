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
    if (_data.isEmpty) return const CircularProgressIndicator();

  return SizedBox(
    height: 300, 
    child: LineChart(
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
  );
   
  }
}
