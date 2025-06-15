import 'package:flutter/material.dart';
import '../../model/Maintenance.model.dart';

class HistoryTable extends StatelessWidget {
  final List<Maintenance> maintenanceList;

  const HistoryTable({Key? key, required this.maintenanceList})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Historique des maintenances",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Technicien')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Coût')),
                ],
                rows:
                    maintenanceList.map((maintenance) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                             'no',
                            ),
                          ),
                         // DataCell(Text(maintenance.type)),
                          //DataCell(Text(maintenance.description)),
                          //DataCell(Text(maintenance.technician)),
                          //DataCell(_buildStatusCell(maintenance.status)),
                          DataCell(
                            Text('${maintenance.cost.toStringAsFixed(2)} €'),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'scheduled':
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case 'cancelled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(status, style: TextStyle(color: color)),
      ],
    );
  }
}
