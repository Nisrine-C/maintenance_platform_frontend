import 'package:flutter/material.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceStatsCard extends StatelessWidget {
  final List<Maintenance> maintenanceList;

  const MaintenanceStatsCard({Key? key, required this.maintenanceList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- FIX: CALCULATE STATS BASED ON THE NEW MODEL ---
    // The 'status' field no longer exists. We now use 'isPreventive'.

    // 1. Count Preventive actions (where isPreventive is true).
    final preventiveCount =
        maintenanceList.where((m) => m.isPreventive).length;

    // 2. Count Corrective actions (where isPreventive is false).
    final correctiveCount =
        maintenanceList.where((m) => !m.isPreventive).length;

    // 3. The totalCost calculation is still valid because the 'cost' field exists.
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
                // --- FIX: DISPLAY THE NEW STATS ---
                _buildStatItem(
                  context,
                  'Preventive', // New Label
                  preventiveCount.toString(),
                  Icons.health_and_safety, // New Icon
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  'Corrective', // New Label
                  correctiveCount.toString(),
                  Icons.warning, // New Icon
                  Colors.orange,
                ),
                _buildStatItem(
                  context,
                  'Total Cost',
                  '\$${totalCost.toStringAsFixed(0)}', // Formatting cost without decimals
                  Icons.attach_money,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // This helper widget does not need to be changed, as it's already generic.
  Widget _buildStatItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Expanded( // Wrap in Expanded to ensure even spacing
      child: Column(
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
      ),
    );
  }
}