import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/app_routes.dart';
import 'package:maintenance_platform_frontend/appBar/appBar.dart';
import 'package:maintenance_platform_frontend/screen/dashbord/dashbord_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maintenance App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DashbordScreen(),
      routes: appRoutes,
    );
  }
}