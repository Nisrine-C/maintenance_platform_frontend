import 'package:flutter/material.dart';
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
  final List<Maintenance> maintenanceList =
      Maintenance.getMockMaintenanceList();
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Widget _buildCurrentMaintenanceCard() {
    // Filtrer les maintenances pour la date sélectionnée
    final maintenancesForDay =
        maintenanceList
            .where((m) => isSameDay(m.scheduledDate, _selectedDay))
            .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maintenance en cours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (maintenancesForDay.isEmpty)
              const Text(
                "Aucune maintenance prévue pour cette date",
                style: TextStyle(fontSize: 16),
              )
            else
              ...maintenancesForDay.map(
                (maintenance) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "${maintenance.type} - ${maintenance.description}\nTechnicien: ${maintenance.technician}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
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
        child: ListView(
          children: [
            const Text(
              "🔧 Maintenance en cours",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildCurrentMaintenanceCard(),
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
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(flex: 1, child: RecommendationCard()),
              ],
            ),
            const SizedBox(height: 30),
            HistoryTable(maintenanceList: maintenanceList),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/maintenance');
        },
        child: const Icon(Icons.add),
        tooltip: 'Programmer une maintenance',
      ),
    );
  }
}
