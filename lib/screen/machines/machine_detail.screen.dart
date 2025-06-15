import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/model/Failure.model.dart';
import 'package:maintenance_platform_frontend/model/SensorData.model.dart';
import 'package:maintenance_platform_frontend/model/Machine.model.dart';
import 'package:maintenance_platform_frontend/model/Prediction.model.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';
import 'package:maintenance_platform_frontend/widget/machines/info_card.dart';
import 'package:maintenance_platform_frontend/widget/machines/maintenance_card.dart';
import 'package:maintenance_platform_frontend/widget/machines/sensor_card.dart';
import '../maintenance/schedule_maintenance.screen.dart';

class Detail extends StatefulWidget {
  final Machine machine;
  final Prediction? prediction;
  final Failure? failure;

  const Detail({
    Key? key,
    required this.machine,
    this.prediction,
    this.failure,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late final Future<List<SensorData>> _sensorDataFuture;
  final SensorDataService _sensorDataService = SensorDataService();

  @override
  void initState() {
    super.initState();
    _sensorDataFuture = _sensorDataService.getSensorDataByMachine(widget.machine.id);
  }

  @override
  Widget build(BuildContext context) {
    final faultInfo = _buildFaultInfo();
    final rulInfo = _buildRULInfo();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.machine.name ?? 'Machine'} Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () => _navigateToScheduleMaintenance(context),
            tooltip: 'Schedule Maintenance',
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStatusInfoRow(faultInfo, rulInfo),
              const SizedBox(height: 16),
              _buildSensorReadingsSection(),
              const SizedBox(height: 20),
              _buildMaintenanceHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.machine.name ?? 'Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStatusInfoRow(Map<String, String> faultInfo, Map<String, dynamic> rulInfo) {
    return Row(
      spacing: 10,
      children: [
        InfoCard(
          title: "Current Status",
          value: faultInfo['value']!,
          subtitle: faultInfo['subtitle']!,
        ),
        InfoCard(
          title: "Remaining Useful Life",
          value: rulInfo['value']!,
          subtitle: rulInfo['subtitle']!,
          showProgress: true,
          progress: rulInfo['progress']!,
        ),
      ],
    );
  }

  Widget _buildSensorReadingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Current Sensor Readings",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<SensorData>>(
          future: _sensorDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sensor data available.'));
            }

            final latestReading = snapshot.data!.last;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSensorCard("Vibration X", latestReading.vibrationX.toStringAsFixed(2), ""),
                _buildSensorCard("Vibration Y", latestReading.vibrationY.toStringAsFixed(2), "m/s²"),
                _buildSensorCard("Speed", latestReading.speedSet.toStringAsFixed(0), "RPM"),
                _buildSensorCard("Load", latestReading.loadValue.toStringAsFixed(1), "%"),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSensorCard(String label, String value, String unit) {
    return SensorCard(
      label: label,
      value: value,
      unit: unit,
    );
  }

  Widget _buildMaintenanceHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Maintenance History",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        MaintenanceCard(
          title: "Tooth Replacement",
          type: "Corrective",
          date: "20/09/2025",
          typeColor: Colors.red[100]!,
          textColor: Colors.red,
        ),
        const SizedBox(height: 10),
        MaintenanceCard(
          title: "Lubrication",
          type: "Preventative",
          date: "14/08/2025",
          typeColor: Colors.green[100]!,
          textColor: Colors.green,
        ),
      ],
    );
  }

  Map<String, String> _buildFaultInfo() {
    if (widget.failure != null) {
      return {
        'value': widget.failure!.faultType ?? 'Failure',
        'subtitle': "Downtime: ${widget.failure!.downtimeHours.toStringAsFixed(1)} hrs",
      };
    } else if (widget.prediction != null) {
      return {
        'value': widget.prediction!.faultType ?? 'Warning',
        'subtitle': "Confidence: ${(widget.prediction!.confidence * 100).toStringAsFixed(1)}%",
      };
    }
    return {
      'value': "OK",
      'subtitle': "No faults detected.",
    };
  }

  Map<String, dynamic> _buildRULInfo() {
    double rulProgress = 1.0;
    String rulValue = "100%";
    String rulSubtitle = "of expected lifetime";

    if (widget.prediction != null && widget.machine.expectedLifetimeHours > 0) {
      rulProgress = (widget.prediction!.predictedRULHours / widget.machine.expectedLifetimeHours);
      rulValue = "${(rulProgress * 100).toStringAsFixed(1)}%";
      rulSubtitle = "${widget.prediction!.predictedRULHours.toStringAsFixed(0)} hours left";
    }

    return {
      'value': rulValue,
      'subtitle': rulSubtitle,
      'progress': rulProgress.clamp(0.0, 1.0),
    };
  }

  void _navigateToScheduleMaintenance(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScheduleMaintenanceScreen(
          machineName: widget.machine.name ?? 'Machine',
        ),
      ),
    );
  }
}