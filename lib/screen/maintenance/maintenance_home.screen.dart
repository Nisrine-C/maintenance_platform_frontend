import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widget/maintanance/calendar_card.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceHomeScreen extends StatefulWidget {
  const MaintenanceHomeScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceHomeScreen> createState() => _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState extends State<MaintenanceHomeScreen> {
  final List<Maintenance> maintenanceList =
      Maintenance.getMockMaintenanceList();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

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
        child: ListView(
          children: [
            const Text(
              "🔧 Maintenance en cours",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Current Maintenance Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Maintenance en cours",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Machine: ${maintenanceList.first.machineId}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Technicien: ${maintenanceList.first.technician}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Type: ${maintenanceList.first.type}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Calendar and Stats Section
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
                          const Text(
                            "Statistiques",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem(
                            "Maintenances prévues",
                            maintenanceList
                                .where((m) => m.status == 'scheduled')
                                .length
                                .toString(),
                            Icons.schedule,
                            Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildStatItem(
                            "Maintenances terminées",
                            maintenanceList
                                .where((m) => m.status == 'completed')
                                .length
                                .toString(),
                            Icons.check_circle,
                            Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Maintenance History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Historique des maintenances",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: maintenanceList.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final maintenance = maintenanceList[index];
                        return ListTile(
                          leading: _getStatusIcon(maintenance.status),
                          title: Text(
                            "Machine ${maintenance.machineId} - ${maintenance.type}",
                          ),
                          subtitle: Text(maintenance.description),
                          trailing: Text(
                            maintenance.scheduledDate.toString().split(" ")[0],
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/maintenance');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'scheduled':
        return const Icon(Icons.schedule, color: Colors.blue);
      case 'cancelled':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }
}
