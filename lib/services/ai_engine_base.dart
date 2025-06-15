import 'dart:async';
import '../model/SensorData.model.dart';

// Base class with common functionality
abstract class AiEngineBase {

  final Map<int, String> _labelMap = {
    0: "eccentricity",
    1: "missing tooth",
    2: "No fault",
    3: "Root crack",
    4: "surface defect",
    5: "chipped tooth",
  };

  static const int windowSize = 100;

  Future<void> initializeAndRun();
  Future<void> processNewReading(SensorData reading);

  /*
  void startSimulatedDataStreams() {
    // Simulate data for machines
    for (int i = 1; i <= 3; i++) {
      _simulateDataForMachine(i);
    }
  }

  void _simulateDataForMachine(int machineId) {
    final random = Random();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      final reading = SensorData(
        id: random.nextInt(1000),
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        loadValue: random.nextDouble() * 80 + 20,
        speedSet: random.nextDouble() * 50 + 50,
        vibrationX: random.nextDouble() * 100,
        vibrationY: random.nextDouble() * 100,
        machineId: machineId,
      );
      processNewReading(reading);
    });
  }
  */

  String getLabelForIndex(int index) {
    return _labelMap[index] ?? "Unknown";
  }
}
