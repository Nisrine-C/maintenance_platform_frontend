import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maintenance_platform_frontend/app_routes.dart';
import 'package:maintenance_platform_frontend/screen/dashbord/dashbord_screen.dart';
import 'package:maintenance_platform_frontend/screen/machines/machines.screen.dart';
import 'package:maintenance_platform_frontend/screen/maintenance/maintenance_home.screen.dart';
import 'package:maintenance_platform_frontend/screen/maintenance/maintenance_management.screen.dart';
import 'package:maintenance_platform_frontend/services/ai_engine_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return Provider<AiEngineService>(
      create: (context) {
        final engine = AiEngineService();
        engine.initializeAndRun();
        print("Provider: AiEngineService created and started.");
        return engine;
      },
      lazy:false,
      dispose: (context, engine) => print("Provider: AiEngineService disposed."),
      child: MaterialApp(
        title: 'Maintenance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/dashboard',
        routes: appRoutes
      ),
    );
  }
}

