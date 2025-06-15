import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../model/Maintenance.model.dart';

class CalendarCard extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Maintenance> maintenanceList;
  final Function(DateTime, DateTime)? onDaySelected;

  const CalendarCard({
    Key? key,
    required this.focusedDay,
    required this.selectedDay,
    required this.maintenanceList,
    this.onDaySelected,
  }) : super(key: key);

  // Helper method to get maintenance events for each day
  List<Maintenance> _getEventsForDay(DateTime day) {
    // --- THE ONLY FIX NEEDED IS HERE ---
    // Change 'maintenance.scheduledDate' to 'maintenance.actionDate'
    return maintenanceList.where((maintenance) {
      return isSameDay(maintenance.actionDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "Maintenance Calendar",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(selectedDay, day),
              onDaySelected: onDaySelected,
              eventLoader: _getEventsForDay, // This now uses the corrected logic
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          // Use a different color for events to distinguish from selected day
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          events.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueGrey,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange, // Keep selected day color distinct
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
                todayTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.red),
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(fontSize: 16),
                leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                rightChevronIcon: Icon(Icons.chevron_right, size: 20),
              ),
              calendarFormat: CalendarFormat.month,
              availableGestures: AvailableGestures.all,
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}