import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/machines/progress_bar.widget.dart';
import '../../constants/colors.dart';
import '../../model/Machine.model.dart';
import '../../widget/machines/info_card.dart';
import '../../widget/machines/maintenance_card.dart';
import '../../widget/machines/sensor_card.dart';
import '../../widget/machines/status_indicator.widget.dart';
import '../maintenance/schedule_maintenance.screen.dart';

class Detail extends StatelessWidget {
  final Machine machine;

  const Detail({Key? key, required this.machine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${machine.name} Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ScheduleMaintenanceScreen(machineName: machine.name),
                ),
              );
            },
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
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(machine.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),

              // Status Info
              Row(
                spacing: 10,
                children: [
                  InfoCard(
                    title: "Fault Code",
                    value: "0",
                    subtitle: "No fault",
                  ),
                  InfoCard(
                    title: "Remaining Useful Life",
                    value: "1%",
                    subtitle: "of expected lifetime",
                    showProgress: true,
                    progress: 1.0,
                  )
                ],
              ),
              const SizedBox(height: 16),

              const Text("Current Sensor Readings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Sensor Data
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  SensorCard(label: "Vibration", value: "13.5", unit: "", alertUp: true),
                  SensorCard(label: "Temperature", value: "24.7", unit: "C", alertUp: false),
                  SensorCard(label: "Speed", value: "1520", unit: "RPM"),
                  SensorCard(label: "Load", value: "78.2%", unit: ""),
                ],
              ),
              const SizedBox(height: 20),

              const Text("Maintenance History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Maintenance history
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
          ),
        ),
      ),
    );
  }
}


