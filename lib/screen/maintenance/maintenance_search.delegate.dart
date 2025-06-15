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
          // Clear the search query
          query = '';
          // Re-run the build to show all results again
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Close the search bar and return null
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Both results and suggestions will use the same builder logic
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  // A private helper method to build the search results UI
  Widget _buildSearchResults() {
    // --- FIX 1: UPDATE THE SEARCH LOGIC ---
    final List<Maintenance> results = query.isEmpty
        ? maintenanceList // If query is empty, show all items
        : maintenanceList.where((maintenance) {
      final queryLower = query.toLowerCase();
      final typeString = (maintenance.isPreventive ? "preventive" : "corrective");

      // Search against the fields that actually exist in the model
      return (maintenance.actionDescription ?? '').toLowerCase().contains(queryLower) ||
          maintenance.machineId.toString().contains(queryLower) ||
          typeString.contains(queryLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          "No maintenance actions found.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // --- FIX 2: UPDATE THE LISTTILE TO DISPLAY CORRECT DATA ---
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final maintenance = results[index];
        final type = maintenance.isPreventive ? 'Preventive' : 'Corrective';
        final icon = maintenance.isPreventive ? Icons.health_and_safety : Icons.warning;
        final color = maintenance.isPreventive ? Colors.blue : Colors.orange;

        return ListTile(
          leading: Icon(icon, color: color),
          title: Text('$type - Machine ${maintenance.machineId}'),
          subtitle: Text(maintenance.actionDescription ?? 'No description available'),
          // Display the 'actionDate' instead of 'scheduledDate'
          trailing: Text(maintenance.actionDate.toString().split(' ')[0]),
          onTap: () {
            // When an item is tapped, close the search and return the selected item
            close(context, maintenance);
          },
        );
      },
    );
  }
}