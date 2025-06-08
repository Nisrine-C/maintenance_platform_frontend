import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/app_routes.dart';
import 'package:maintenance_platform_frontend/screen/appBar/home.dart';

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
      home: HomeBar(),
      routes: appRoutes,
    );
  }
}