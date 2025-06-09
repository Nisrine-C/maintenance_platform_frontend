import 'dart:math';
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';

// This file is only used in native platforms (Windows, Linux, macOS)
class AiEngineServiceNative extends AiEngineBase {
  final _random = Random();
  final Map<int, List<SensorData>> _dataBuffers = {};
  final Map<int, DateTime> _lastPredictionTime = {};

  @override
  Future<void> initializeAndRun() async {
    print("AI Engine Native: Initializing...");
    // In native implementation, we would initialize ONNX here
    // But for now, we'll use simulated data
    startSimulatedDataStreams();
    print("AI Engine Native: Running and processing data streams...");
  }

  @override
  Future<void> processNewReading(SensorData reading) async {
    try {
      if (!_dataBuffers.containsKey(reading.machineId)) {
        _dataBuffers[reading.machineId] = [];
      }

      final buffer = _dataBuffers[reading.machineId]!;
      buffer.add(reading);

      // Check if it's time for a new prediction
      final lastPrediction =
          _lastPredictionTime[reading.machineId] ??
          DateTime.fromMillisecondsSinceEpoch(0);
      if (DateTime.now().difference(lastPrediction).inMinutes >= 5 ||
          buffer.length >= AiEngineBase.windowSize) {
        _generatePrediction(reading.machineId, buffer);
        _lastPredictionTime[reading.machineId] = DateTime.now();

        // Clear buffer if it's full
        if (buffer.length >= AiEngineBase.windowSize) {
          buffer.clear();
        }
      }
    } catch (e, stackTrace) {
      print(
        "AI Engine Native: Error processing reading for machine ${reading.machineId}",
      );
      print(e);
      print(stackTrace);
    }
  }

  void _generatePrediction(int machineId, List<SensorData> buffer) {
    if (buffer.isEmpty) return;

    try {
      // Calculate statistics from the buffer
      final vibrationXValues = buffer.map((d) => d.vibrationX).toList();
      final vibrationYValues = buffer.map((d) => d.vibrationY).toList();
      final loadValues = buffer.map((d) => d.loadValue).toList();

      final vibXMean =
          vibrationXValues.reduce((a, b) => a + b) / vibrationXValues.length;
      final vibYMean =
          vibrationYValues.reduce((a, b) => a + b) / vibrationYValues.length;
      final loadMean = loadValues.reduce((a, b) => a + b) / loadValues.length;

      // Calculate variability
      final vibXVar =
          vibrationXValues
              .map((v) => (v - vibXMean) * (v - vibXMean))
              .reduce((a, b) => a + b) /
          vibrationXValues.length;
      final vibYVar =
          vibrationYValues
              .map((v) => (v - vibYMean) * (v - vibYMean))
              .reduce((a, b) => a + b) /
          vibrationYValues.length;

      // Generate anomaly score based on means and variances
      final double anomalyScore =
          (vibXMean - 50).abs() +
          (vibYMean - 50).abs() +
          (loadMean - 70).abs() +
          (vibXVar > 100 ? 20 : 0) +
          (vibYVar > 100 ? 20 : 0);

      String faultType;
      double confidence;
      double rul;

      if (anomalyScore < 30) {
        faultType = getLabelForIndex(2); // No fault
        confidence = 0.95 + _random.nextDouble() * 0.05;
        rul = 10000 + _random.nextDouble() * 2000;
      } else if (anomalyScore < 60) {
        if (vibXVar > vibYVar) {
          faultType = getLabelForIndex(0); // eccentricity
        } else {
          faultType = getLabelForIndex(4); // surface defect
        }
        confidence = 0.85 + _random.nextDouble() * 0.1;
        rul = 5000 + _random.nextDouble() * 2000;
      } else {
        if (loadMean > 90) {
          faultType = getLabelForIndex(3); // Root crack
        } else if (vibXVar > 150 || vibYVar > 150) {
          faultType = getLabelForIndex(5); // chipped tooth
        } else {
          faultType = getLabelForIndex(1); // missing tooth
        }
        confidence = 0.75 + _random.nextDouble() * 0.15;
        rul = 2000 + _random.nextDouble() * 1000;
      }

      final prediction = Prediction(
        id: _random.nextInt(1000),
        createdAt: DateTime.now(),
        isActive: true,
        updatedAt: DateTime.now(),
        confidence: confidence,
        faultType: faultType,
        predictedRULHours: rul,
        machineId: machineId,
      );

      print(
        "Generated prediction for machine $machineId: ${prediction.faultType} (Confidence: ${prediction.confidence.toStringAsFixed(2)}, RUL: ${rul.toStringAsFixed(0)} hours)",
      );
    } catch (e, stackTrace) {
      print(
        "AI Engine Native: Error generating prediction for machine $machineId",
      );
      print(e);
      print(stackTrace);
    }
  }
}
