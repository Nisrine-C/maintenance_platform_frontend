import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maintenance_platform_frontend/screen/machines/machines.screen.dart';
import 'package:maintenance_platform_frontend/services/ai_engine_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This ensures the status bar is transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    // 1. Wrap your MaterialApp with a Provider.
    return Provider<AiEngineService>(
      // 2. The 'create' callback is where the service is created and started.
      // It's called only once when the app starts up.
      create: (context) {
        final engine = AiEngineService();
        // Tell the engine to initialize and run in the background.
        engine.initializeAndRun();
        print("Provider: AiEngineService created and started.");
        return engine;
      },
      lazy:false,
      // 3. 'dispose' is good practice for cleaning up resources when the app closes.
      dispose: (context, engine) => print("Provider: AiEngineService disposed."),
      child: MaterialApp(
        title: 'Maintenance App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Set your initial screen here
        home: MachinesScreen(),
      ),
    );
  }
}

