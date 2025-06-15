// FILE: HomeScreen.dart

import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/services/Maintenance_service.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widget/maintanance/calendar_card.dart';
import '../../widget/maintanance/recommendation_card.dart';
import '../../widget/maintanance/history_table.dart';
import '../../model/Maintenance.model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  // Updated to use the new Maintenance model fields.
  Widget _buildCurrentMaintenanceCard(List<Maintenance> maintenanceList) {
    // Filter maintenances for the selected day using the correct date field.
    final maintenancesForDay = maintenanceList
        .where((m) => isSameDay(m.actionDate, _selectedDay))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maintenance Actions for Selected Day",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (maintenancesForDay.isEmpty)
              const Text(
                "No maintenance actions scheduled for this date.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
            // Create a list of widgets from the filtered data.
              ...maintenancesForDay.map(
                    (maintenance) {
                  // Determine the type based on the 'isPreventive' boolean.
                  final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // Display the type and machine ID.
                          "$type Action - Machine ${maintenance.machineId}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          // Use the 'actionDescription' field, with a fallback.
                          maintenance.actionDescription ?? 'No description provided.',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          // Display the cost.
                          "Cost: \$${maintenance.cost.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 14, color: Colors.green),
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
                  "🔧 Maintenance Dashboard",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildCurrentMaintenanceCard(maintenanceList), // This now works
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CalendarCard(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        maintenanceList: maintenanceList, // Pass the new model list
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: RecommendationCard()), // Assuming this is static
                  ],
                ),
                const SizedBox(height: 30),
                HistoryTable(maintenanceList: maintenanceList), // Pass the new model list
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
        tooltip: 'Programmer une maintenance',
      ),
    );
  }
}