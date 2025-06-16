import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/model/Failure.model.dart';
import 'package:maintenance_platform_frontend/model/SensorData.model.dart';
import 'package:maintenance_platform_frontend/model/Machine.model.dart';
import 'package:maintenance_platform_frontend/model/Prediction.model.dart';
import 'package:maintenance_platform_frontend/screen/machines/update_machine.screen.dart';
import 'package:maintenance_platform_frontend/services/machine_service.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';
import 'package:maintenance_platform_frontend/widget/machines/info_card.dart';
import 'package:maintenance_platform_frontend/widget/machines/maintenance_card.dart';
import 'package:maintenance_platform_frontend/widget/machines/sensor_card.dart';
import '../maintenance/schedule_maintenance.screen.dart';

class Detail extends StatefulWidget {
  late Machine machine;

  final Prediction? prediction;
  final Failure? failure;


  Detail({
    Key? key,
    required this.machine,
    this.prediction,
    this.failure,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late Future<List<SensorData>> _sensorDataFuture;
  late final MachineService _machineService = MachineService();
  late final SensorDataService _sensorDataService = SensorDataService();
  late Machine _machine;


  @override
  void initState() {
    super.initState();
    _machine = widget.machine;

    if (widget.machine.id != null) {
      _sensorDataFuture = _sensorDataService.getSensorDataByMachine(widget.machine.id!);
    } else {
      _sensorDataFuture = Future.error('Machine ID is missing. Cannot load data.');
    }
  }
  void _deleteMachine() async {
    // A. Show a confirmation dialog to the user first!
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this machine? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    // B. If the user confirmed, then call the service.
    if (confirmed == true && widget.machine.id != null) {
      try {
        await _machineService.deleteMachine(widget.machine.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Machine deleted successfully')));
          Navigator.pop(context,true ); // Go back to the previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting machine: $e')));
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final faultInfo = _buildFaultInfo();
    final rulInfo = _buildRULInfo();

    return Scaffold(
      appBar: AppBar(
        title: Text("${_machine.name ?? 'Machine'} Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteMachine,
            tooltip: 'Delete Machine',
          ),
          IconButton(
            icon: const Icon(Icons.update_sharp),
            onPressed: () => _navigateToUpdateMachine(context),
            tooltip: 'Update Machine',
          ),
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
          _machine.name ?? 'Details',
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

    if (widget.prediction != null && _machine.expectedLifetimeHours > 0) {
      rulProgress = (widget.prediction!.predictedRULHours / _machine.expectedLifetimeHours);
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
          machineName: _machine.name ?? 'Machine',
        ),
      ),
    );
  }
  void _navigateToUpdateMachine(BuildContext context) async{
    final machine = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateMachineForm(
          machine: _machine,
        ),
      ),
    );

    if (machine != null && machine is Machine) {
      setState(() {
        _machine = machine;
        _sensorDataFuture = _sensorDataService.getSensorDataByMachine(machine.id!);
      });
    }
  }
}