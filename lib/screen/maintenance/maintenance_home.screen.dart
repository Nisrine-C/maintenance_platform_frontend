// FILE: MaintenanceHomeScreen.dart

import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/services/Maintenance_service.dart';
import '../../widget/maintanance/calendar_card.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceHomeScreen extends StatefulWidget {
  const MaintenanceHomeScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceHomeScreen> createState() => _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState extends State<MaintenanceHomeScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  late Future<List<Maintenance>> _maintenanceFuture;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMaintenanceData();
  }

  Future<void> _loadMaintenanceData() async {
    setState(() {
      _maintenanceFuture = _maintenanceService.getMaintenances();
    });
  }

  // --- MODIFIED WIDGET ---
  Widget _buildCurrentMaintenanceCard(List<Maintenance> maintenanceList) {
    // Define "current" as any action scheduled for today or in the future.
    final upcomingMaintenance = maintenanceList
        .where((m) => m.actionDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Upcoming Maintenance Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (upcomingMaintenance.isEmpty)
              const Text(
                "No upcoming maintenance actions.",
                style: TextStyle(fontSize: 16),
              )
            else
              ...upcomingMaintenance.map(
                    (maintenance) {
                  final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Machine ${maintenance.machineId} - $type",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Date: ${maintenance.actionDate.toString().split(" ")[0]}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          maintenance.actionDescription ?? 'No description.',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plateforme de Maintenance Prédictive"),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(child: Text("P")),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Maintenance>>(
          future: _maintenanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No maintenance data available.'));
            }

            final maintenanceList = snapshot.data!;

            return ListView(
              children: [
                const Text(
                  "🔧 Maintenance Actions",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildCurrentMaintenanceCard(maintenanceList),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CalendarCard(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        maintenanceList: maintenanceList,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16),
                              // --- MODIFIED STATS ---
                              _buildStatItem(
                                "Preventive",
                                maintenanceList.where((m) => m.isPreventive).length.toString(),
                                Icons.health_and_safety, Colors.blue,
                              ),
                              const SizedBox(height: 16),
                              _buildStatItem(
                                "Corrective",
                                maintenanceList.where((m) => !m.isPreventive).length.toString(),
                                Icons.warning, Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("History of Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        // --- MODIFIED HISTORY LIST ---
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: maintenanceList.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final maintenance = maintenanceList[index];
                            final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
                            return ListTile(
                              leading: Icon(
                                maintenance.isPreventive ? Icons.health_and_safety : Icons.warning,
                                color: maintenance.isPreventive ? Colors.blue : Colors.orange,
                              ),
                              title: Text("Machine ${maintenance.machineId} - $type"),
                              subtitle: Text(maintenance.actionDescription ?? 'No description.'),
                              trailing: Text(
                                maintenance.actionDate.toString().split(" ")[0],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/maintenance').then((_) {
            _loadMaintenanceData();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}