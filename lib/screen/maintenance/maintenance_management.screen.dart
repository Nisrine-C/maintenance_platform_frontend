// FILE: MaintenanceManagementScreen.dart

import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/services/Maintenance_service.dart';
import 'package:maintenance_platform_frontend/model/Maintenance.model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widget/maintanance/maintenance_history_card.dart';
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
  final MaintenanceService _maintenanceService = MaintenanceService();
  late Future<List<Maintenance>> _maintenanceFuture;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMaintenanceData();
  }

  Future<void> _loadMaintenanceData() async {
    setState(() {
      _maintenanceFuture = _maintenanceService.getMaintenances();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              final maintenanceList = await _maintenanceFuture;
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
                  builder: (context) => const ScheduleMaintenanceScreen(
                    machineName: 'New Maintenance Action',
                  ),
                ),
              ).then((_) => _loadMaintenanceData());
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Maintenance>>(
        future: _maintenanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No maintenance data available'));
          }

          final maintenanceList = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDashboardTab(maintenanceList),
              _buildCalendarTab(maintenanceList),
              _buildHistoryTab(maintenanceList),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  Widget _buildDashboardTab(List<Maintenance> maintenanceList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_buildQuickStats(maintenanceList),
          const SizedBox(height: 16),
          _buildUpcomingActionsSection(maintenanceList),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(List<Maintenance> maintenanceList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CalendarCard(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            maintenanceList: maintenanceList,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          MaintenanceHistoryCard( // Assuming this widget can be adapted or replaced
            maintenanceList: _getMaintenanceForSelectedDay(maintenanceList),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<Maintenance> maintenanceList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: HistoryTable(maintenanceList: maintenanceList),
    );
  }

  Widget _buildUpcomingActionsSection(List<Maintenance> maintenanceList) {
    final upcomingActions = maintenanceList
        .where((m) => m.actionDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (upcomingActions.isEmpty)
              const Center(child: Text('No upcoming actions scheduled.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingActions.length,
                itemBuilder: (context, index) {
                  final maintenance = upcomingActions[index];
                  final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
                  return ListTile(
                    leading: Icon(Icons.build, color: maintenance.isPreventive ? Colors.blue : Colors.orange),
                    title: Text('$type - Machine ${maintenance.machineId}'),
                    subtitle: Text('Scheduled: ${maintenance.actionDate.toString().split(' ')[0]}'),
                    onTap: () => _showMaintenanceDetails(context, maintenance),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /*
  Widget _buildQuickStats(List<Maintenance> maintenanceList) {
    final totalCost = maintenanceList.fold(0.0, (sum, m) => sum + m.cost);
    final preventiveCount = maintenanceList.where((m) => m.isPreventive).length;
    final correctiveCount = maintenanceList.where((m) => !m.isPreventive).length;

    /*
    return MaintenanceStatsCard( // Using your custom widget
      preventiveCount: preventiveCount,
      correctiveCount: correctiveCount,
      totalCost: totalCost,
    );*/
  }*/

  List<Maintenance> _getMaintenanceForSelectedDay(List<Maintenance> maintenanceList) {
    return maintenanceList
        .where((m) => isSameDay(m.actionDate, _selectedDay))
        .toList();
  }

  void _showMaintenanceDetails(BuildContext context, Maintenance maintenance) {
    final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$type Action Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Machine ID', maintenance.machineId.toString()),
              _detailRow('Action Date', maintenance.actionDate.toString().split(' ')[0]),
              _detailRow('Cost', '€${maintenance.cost.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(maintenance.actionDescription ?? 'No description provided.'),
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
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}