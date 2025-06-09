import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/model/Maintenance.model.dart';
import '../../widget/maintanance/maintenance_history_card.dart';
import '../../widget/maintanance/maintenance_stats_card.dart';
import '../../widget/maintanance/calendar_card.dart';

class MaintenanceManagementScreen extends StatefulWidget {
  const MaintenanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceManagementScreen> createState() =>
      _MaintenanceManagementScreenState();
}

class _MaintenanceManagementScreenState
    extends State<MaintenanceManagementScreen> {
  late List<Maintenance> maintenanceList;
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    maintenanceList = Maintenance.getMockMaintenanceList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement new maintenance scheduling
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MaintenanceStatsCard(maintenanceList: maintenanceList),
            const SizedBox(height: 16),
            CalendarCard(focusedDay: focusedDay),
            const SizedBox(height: 16),
            MaintenanceHistoryCard(maintenanceList: maintenanceList),
          ],
        ),
      ),
    );
  }
}
