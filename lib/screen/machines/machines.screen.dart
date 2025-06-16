import 'package:flutter/material.dart';

import '../../appBar/appBar.dart';
import '../../constants/colors.dart';
import '../../model/Failure.model.dart';
import '../../model/Machine.model.dart';
import '../../model/Prediction.model.dart';
import '../../services/failure_service.dart';
import '../../services/machine_service.dart';
import '../../services/prediction_service.dart';
import '../../widget/machines/machine_item.widget.dart';
import '../../widget/machines/status_indicator.widget.dart';
import 'create_machine.screen.dart';
import 'machine_detail.screen.dart';

class MachinesDashboardData {
  final List<Machine> machines;
  final List<Prediction> predictions;
  final List<Failure> failures;

  MachinesDashboardData({
    required this.machines,
    required this.predictions,
    required this.failures,
  });
}

class MachinesScreen extends StatefulWidget {
  const MachinesScreen({Key? key}) : super(key: key);

  @override
  State<MachinesScreen> createState() => _MachinesScreenState();
}

class _MachinesScreenState extends State<MachinesScreen> {
  final MachineService _machineService = MachineService();
  final PredictionService _predictionService = PredictionService();
  final FailureService _failureService = FailureService();

  late Future<MachinesDashboardData> _dashboardDataFuture;

  @override
  void initState() {
    super.initState();
    // Load all data when the screen initializes
    _dashboardDataFuture = _loadDashboardData();
  }

  /// Fetches all required data from the API concurrently.
  Future<MachinesDashboardData> _loadDashboardData() async {
    try {
      // Use Future.wait to run all API calls in parallel for great performance!
      final results = await Future.wait([
        _machineService.getMachines(),
        _predictionService.getPredictions(),
        _failureService.getFailures(),
      ]);

      // Create and return our data holder object
      return MachinesDashboardData(
        machines: results[0] as List<Machine>,
        predictions: results[1] as List<Prediction>,
        failures: results[2] as List<Failure>,
      );
    } catch (e) {
      print("Error loading dashboard data: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToCreateMachine(context),
            tooltip: 'Create Machine',
          ),
        ],
      ),
      drawer: buildHomeDrawer(context),
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusIndicator(label: 'OK',
                    icon: Icons.check_circle,
                    backgroundColor: tdGreen,
                    iconColor: textGreen,
                    textColor: textGreen),
                StatusIndicator(label: 'Warning',
                    icon: Icons.error,
                    backgroundColor: tdYellow,
                    iconColor: textYellow,
                    textColor: textYellow),
                StatusIndicator(label: 'Failure',
                    icon: Icons.cancel,
                    backgroundColor: tdRed,
                    iconColor: textRed,
                    textColor: textRed),
              ],
            ),
            Expanded(
              child: FutureBuilder<MachinesDashboardData>(
                future: _dashboardDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error loading data: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.machines.isEmpty) {
                    return const Center(child: Text('No machines found.'));
                  }

                  final liveMachines = snapshot.data!.machines;
                  final predictionsMap = {
                    for (var p in snapshot.data!.predictions) p.machineId: p
                  };
                  final failuresMap = {
                    for (var f in snapshot.data!.failures) f.machineId: f
                  };

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: liveMachines.length,
                    itemBuilder: (context, index) {
                      final machine = liveMachines[index];
                      final prediction = predictionsMap[machine.id];
                      final failure = failuresMap[machine.id];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Detail(
                                      machine: machine,
                                      prediction: prediction,
                                      failure: failure
                                  ),
                            ),
                          );
                        },
                        child: MachineItem(
                          machine: machine,
                          failure: failure,
                          prediction: prediction,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreateMachine(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateMachineForm()),
    );

    if (result == true) {
      setState(() {
        _dashboardDataFuture=_loadDashboardData();
      });
    }
  }

}
