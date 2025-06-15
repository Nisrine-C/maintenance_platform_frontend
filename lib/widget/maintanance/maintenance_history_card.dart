import 'package:flutter/material.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceHistoryCard extends StatelessWidget {
  final List<Maintenance> maintenanceList;

  const MaintenanceHistoryCard({Key? key, required this.maintenanceList})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: maintenanceList.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final maintenance = maintenanceList[index];
                /*
                return ListTile(
                  leading: _getStatusIcon(maintenance.status),
                  title: Text(maintenance.type),
                  subtitle: Text(maintenance.description),
                  trailing: Text(
                    'Cost: \$${maintenance.cost.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _showMaintenanceDetails(context, maintenance);
                  },
                );*/
              },
            ),
          ],
        ),
      ),
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
/*
  void _showMaintenanceDetails(BuildContext context, Maintenance maintenance) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(maintenance.type),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detailRow('Status', maintenance.status),
                  _detailRow(
                    'Date',
                    maintenance.scheduledDate.toString().split(' ')[0],
                  ),
                  _detailRow('Duration', '${maintenance.duration} hours'),
                  _detailRow('Technician', maintenance.technician),
                  _detailRow(
                    'Cost',
                    '\$${maintenance.cost.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tasks:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...maintenance.tasks
                      .map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('• $task'),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 8),
                  const Text(
                    'Description:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(maintenance.description),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }*/

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
