import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/alert_card.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/gear_status_card.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/graph_section.dart';

class DashboardSecsion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatutGlobalSection(),
          SizedBox(height: 16),
          AlertsSection(),
          SizedBox(height: 16),
          GraphSection(machineId: 1),
        ],
      ),
    );
  }
}
