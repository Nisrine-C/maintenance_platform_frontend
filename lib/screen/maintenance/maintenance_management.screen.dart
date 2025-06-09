import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/model/Maintenance.model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widget/maintanance/maintenance_history_card.dart';
import '../../widget/maintanance/maintenance_stats_card.dart';
import '../../widget/maintanance/calendar_card.dart';
import '../../widget/maintanance/history_table.dart';
import 'schedule_maintenance.screen.dart';
import 'maintenance_search.delegate.dart';

class MaintenanceManagementScreen extends StatefulWidget {
  const MaintenanceManagementScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceManagementScreen> createState() =>
      _MaintenanceManagementScreenState();
}

class _MaintenanceManagementScreenState
    extends State<MaintenanceManagementScreen>
    with SingleTickerProviderStateMixin {
  List<Maintenance> maintenanceList = [];
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    maintenanceList = Maintenance.getMockMaintenanceList();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Maintenance> get filteredMaintenances {
    return maintenanceList.where((maintenance) {
      final query = _searchQuery.toLowerCase();
      return maintenance.type.toLowerCase().contains(query) ||
          maintenance.description.toLowerCase().contains(query) ||
          maintenance.technician.toLowerCase().contains(query) ||
          maintenance.machineId.toString().contains(query);
    }).toList();
  }

  void _updateMaintenanceStatus(Maintenance maintenance, String newStatus) {
    setState(() {
      final index = maintenanceList.indexWhere((m) => m.id == maintenance.id);
      if (index != -1) {
        maintenanceList[index] = Maintenance(
          id: maintenance.id,
          createdAt: maintenance.createdAt,
          scheduledDate: maintenance.scheduledDate,
          status: newStatus,
          type: maintenance.type,
          description: maintenance.description,
          machineId: maintenance.machineId,
          technician: maintenance.technician,
          duration: maintenance.duration,
          tasks: maintenance.tasks,
          cost: maintenance.cost,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.calendar_month), text: 'Calendar'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: MaintenanceSearchDelegate(maintenanceList),
              );
              if (result != null) {
                _showMaintenanceDetails(context, result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => const ScheduleMaintenanceScreen(
                        machineName: 'New Maintenance',
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Dashboard
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaintenanceStatsCard(maintenanceList: maintenanceList),
                const SizedBox(height: 16),
                _buildCurrentMaintenanceSection(),
                const SizedBox(height: 16),
                _buildQuickStats(),
              ],
            ),
          ),
          // Calendar View
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CalendarCard(
                  focusedDay: _focusedDay,
                  selectedDay: _selectedDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                const SizedBox(height: 16),
                MaintenanceHistoryCard(
                  maintenanceList: _getMaintenanceForSelectedDay(),
                ),
              ],
            ),
          ),
          // History View
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMaintenanceHistoryFilters(),
                const SizedBox(height: 16),
                HistoryTable(maintenanceList: _getFilteredMaintenanceList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMaintenanceSection() {
    final currentMaintenance =
        maintenanceList.where((m) => m.status == 'scheduled').toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Maintenance Schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Schedule New'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => const ScheduleMaintenanceScreen(
                              machineName: 'New Maintenance',
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentMaintenance.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No maintenance currently scheduled',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentMaintenance.length,
                itemBuilder: (context, index) {
                  final maintenance = currentMaintenance[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: const Icon(Icons.build, color: Colors.blue),
                      title: Text(
                        '${maintenance.type} - Machine ${maintenance.machineId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(maintenance.description),
                          const SizedBox(height: 4),
                          Text(
                            'Scheduled: ${maintenance.scheduledDate.toString().split(' ')[0]}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            color: Colors.green,
                            tooltip: 'Mark as completed',
                            onPressed: () {
                              _updateMaintenanceStatus(
                                maintenance,
                                'completed',
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                            tooltip: 'Mark as cancelled',
                            onPressed: () {
                              _updateMaintenanceStatus(
                                maintenance,
                                'cancelled',
                              );
                            },
                          ),
                        ],
                      ),
                      onTap:
                          () => _showMaintenanceDetails(context, maintenance),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final completedCount =
        maintenanceList.where((m) => m.status == 'completed').length;
    final scheduledCount =
        maintenanceList.where((m) => m.status == 'scheduled').length;
    final totalCost = maintenanceList
        .where((m) => m.status == 'completed')
        .fold(0.0, (sum, m) => sum + m.cost);
    final averageDuration =
        completedCount > 0
            ? maintenanceList
                    .where((m) => m.status == 'completed')
                    .fold(0.0, (sum, m) => sum + m.duration) /
                completedCount
            : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.check_circle,
                  completedCount.toString(),
                  'Completed',
                  Colors.green,
                ),
                _buildStatItem(
                  Icons.pending_actions,
                  scheduledCount.toString(),
                  'Scheduled',
                  Colors.blue,
                ),
                _buildStatItem(
                  Icons.euro,
                  totalCost.toStringAsFixed(0),
                  'Total Cost',
                  Colors.orange,
                ),
                _buildStatItem(
                  Icons.timer,
                  averageDuration.toStringAsFixed(1),
                  'Avg Hours',
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        ],
      ),
    );
  }

  List<Maintenance> _getMaintenanceForSelectedDay() {
    return maintenanceList
        .where((m) => isSameDay(m.scheduledDate, _selectedDay))
        .toList();
  }

  Widget _buildMaintenanceHistoryFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('Completed'),
                  selected: true,
                  onSelected: (bool selected) {
                    // Implement filter logic
                  },
                ),
                FilterChip(
                  label: const Text('Scheduled'),
                  selected: true,
                  onSelected: (bool selected) {
                    // Implement filter logic
                  },
                ),
                FilterChip(
                  label: const Text('Cancelled'),
                  selected: true,
                  onSelected: (bool selected) {
                    // Implement filter logic
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Maintenance> _getFilteredMaintenanceList() {
    // For now, return all maintenance items
    // You can implement filtering logic based on the selected filters
    return maintenanceList;
  }

  void _showMaintenanceDetails(BuildContext context, Maintenance maintenance) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  maintenance.status == 'completed'
                      ? Icons.check_circle
                      : maintenance.status == 'scheduled'
                      ? Icons.schedule
                      : Icons.cancel,
                  color:
                      maintenance.status == 'completed'
                          ? Colors.green
                          : maintenance.status == 'scheduled'
                          ? Colors.blue
                          : Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(maintenance.type)),
              ],
            ),
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
                  _detailRow('Cost', '€${maintenance.cost.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Tasks:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...maintenance.tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text('• $task'),
                    ),
                  ),
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
              if (maintenance.status == 'scheduled') ...[
                TextButton.icon(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  label: const Text('Mark Completed'),
                  onPressed: () {
                    _updateMaintenanceStatus(maintenance, 'completed');
                    Navigator.of(context).pop();
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('Mark Cancelled'),
                  onPressed: () {
                    _updateMaintenanceStatus(maintenance, 'cancelled');
                    Navigator.of(context).pop();
                  },
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

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
