import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maintenance_platform_frontend/model/HistogramBin.dart';
import 'package:maintenance_platform_frontend/services/DashbordService/SensorDataService.dart';


class VibrationHistogram extends StatefulWidget {
  final int machineId;

  const VibrationHistogram({super.key, required this.machineId});

  @override
  State<VibrationHistogram> createState() => _VibrationHistogramState();
}

class _VibrationHistogramState extends State<VibrationHistogram> {
  final SensorService _service = SensorService();
  List<HistogramBin> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchHistogram();
  }

  void _fetchHistogram() async {
    final histogram = await _service.getHistogram(widget.machineId);
    setState(() {
      _data = histogram;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final barGroups = _data.asMap().entries.map((entry) {
      final index = entry.key;
      final bin = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: bin.count.toDouble(),
            color: Colors.teal,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    }).toList();

    return SizedBox(
    height: 400, // or whatever height you prefer
    child: Column(
      children: [
        const Text("Histogramme des vibrations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded( // Make the chart take remaining space
          child: AspectRatio(
            aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _data.length) return const SizedBox();
                      return Transform.rotate(
                        angle: -0.5,
                        child: Text(_data[index].range, style: const TextStyle(fontSize: 10)),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: true),
            ),
          ),
        ),),
      ],
    ),
    );
  }
}
