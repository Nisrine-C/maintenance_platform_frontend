import 'package:flutter/material.dart';
import '../maintenance/schedule_maintenance.screen.dart';

class Detail extends StatelessWidget {
  final String machine;

  const Detail({Key? key, required this.machine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$machine Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.build),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ScheduleMaintenanceScreen(machineName: machine),
                ),
              );
            },
            tooltip: 'Schedule Maintenance',
          ),
        ],
      ),
      body: const Center(
        child: Text('Machine Details Page', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
