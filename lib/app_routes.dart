import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/appBar/appBar.dart';
import 'package:maintenance_platform_frontend/screen/dashbord/dashbord_screen.dart';
import 'package:maintenance_platform_frontend/screen/machines/machines.screen.dart';
import 'package:maintenance_platform_frontend/screen/maintenance/maintenance_management.screen.dart';
import 'package:maintenance_platform_frontend/screen/maintenance/maintenance_home.screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/dashbord': (context) => DashbordScreen(),
  '/machines': (context) => MachinesScreen(),
  '/maintenance': (context) => const MaintenanceManagementScreen(),
  '/maintenance_home': (context) => MaintenanceHomeScreen(),
};
