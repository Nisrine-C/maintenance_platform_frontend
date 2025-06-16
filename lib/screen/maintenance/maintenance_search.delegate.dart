import 'package:flutter/material.dart';
import '../../model/Maintenance.model.dart';

class MaintenanceSearchDelegate extends SearchDelegate<Maintenance?> {
  final List<Maintenance> maintenanceList;

  MaintenanceSearchDelegate(this.maintenanceList);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildSearchResults();
  }

  Widget buildSearchResults() {
    final results =
        maintenanceList.where((maintenance) {
          final queryLower = query.toLowerCase();
          return maintenance.type.toLowerCase().contains(queryLower) ||
              maintenance.description.toLowerCase().contains(queryLower) ||
              maintenance.technician.toLowerCase().contains(queryLower) ||
              maintenance.machineId.toString().contains(queryLower);
        }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final maintenance = results[index];
        return ListTile(
          leading: Icon(
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
          title: Text('${maintenance.type} - Machine ${maintenance.machineId}'),
          subtitle: Text(maintenance.description),
          trailing: Text(maintenance.scheduledDate.toString().split(' ')[0]),
          onTap: () {
            close(context, maintenance);
          },
        );
      },
    );
  }
}
