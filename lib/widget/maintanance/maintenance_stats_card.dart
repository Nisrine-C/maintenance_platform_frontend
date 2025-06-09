import 'package:flutter/material.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceStatsCard extends StatelessWidget {
  final List<Maintenance> maintenanceList;

  const MaintenanceStatsCard({Key? key, required this.maintenanceList})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completedCount =
        maintenanceList.where((m) => m.status == 'completed').length;
    final scheduledCount =
        maintenanceList.where((m) => m.status == 'scheduled').length;
    final totalCost = maintenanceList.fold(0.0, (sum, m) => sum + m.cost);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Completed',
                  completedCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  context,
                  'Scheduled',
                  scheduledCount.toString(),
                  Icons.schedule,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Total Cost',
                  '\$${totalCost.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
