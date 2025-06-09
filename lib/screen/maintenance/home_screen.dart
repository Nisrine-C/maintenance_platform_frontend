import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/calendar_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/history_table.dart';

class HomeScreen extends StatelessWidget {
  final DateTime _focusedDay = DateTime.utc(2024, 4, 19);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Plateforme de Maintenance Prédictive"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(child: Text("P")),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text("🔧 Maintenance en cours",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(
              "La ligne de production A est actuellement en maintenance pour analyse vibratoire. Fin prévue le 24 avr. 2024, 14:30.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: CalendarCard(focusedDay: _focusedDay)),
                SizedBox(width: 20),
                Expanded(child: RecommendationCard()),
              ],
            ),
            SizedBox(height: 30),
            HistoryTable(),
          ],
        ),
      ),
    );
  }
}