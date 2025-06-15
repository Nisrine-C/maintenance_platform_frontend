import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:maintenance_platform_frontend/services/prediction_service.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';

import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';

class AiEngineServiceWeb extends AiEngineBase {
  // State Management
  /// A buffer to store recent sensor readings for each machine, keyed by machineId.
  final Map<int, List<SensorData>> _dataBuffers = {};
  /// Tracks the last time a prediction was generated for a machine to avoid overuse.
  final Map<int, DateTime> _lastPredictionTime = {};
  /// Stores the IDs of all readings that have already been processed to avoid duplicates.
  final Set<int> _processedReadingIds = {};

  // Service Dependencies
  /// Service to communicate with the backend's sensor data endpoints.
  final SensorDataService _sensorDataService = SensorDataService();
  /// Service to send new predictions to the backend.
  final PredictionService _predictionService = PredictionService();


  @override
  Future<void> initializeAndRun() async {
    print("AI Engine (Web): Initializing and starting data polling...");
    _startDataProcessingLoop();
  }

  // Starts a periodic timer to poll the backend for sensor data.
  void _startDataProcessingLoop() {
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      debugPrint("AI Engine: Polling for sensor data...");
      try {
        final List<SensorData> allReadings =
        await _sensorDataService.getSensorDatas();

        for (final reading in allReadings) {
          if (!_processedReadingIds.contains(reading.id)) {
            await processNewReading(reading);
            _processedReadingIds.add(reading.id);
          }
        }
      } catch (e) {
        print("AI Engine (Web) ERROR: Failed to fetch sensor data: $e");
      }
    });
  }

  @override
  Future<void> processNewReading(SensorData reading) async {
    if (!_dataBuffers.containsKey(reading.machineId)) {
      _dataBuffers[reading.machineId] = [];
    }

    final buffer = _dataBuffers[reading.machineId]!;
    buffer.add(reading);

    final lastPrediction = _lastPredictionTime[reading.machineId] ?? DateTime.fromMillisecondsSinceEpoch(0);
    final now = DateTime.now();

    // Trigger a prediction if it's been 5+ minutes or the buffer is full.
    if (now.difference(lastPrediction).inMinutes >= 5 || buffer.length >= AiEngineBase.windowSize) {
      _triggerPrediction(reading.machineId, buffer);
      _lastPredictionTime[reading.machineId] = now;

      if (buffer.length >= AiEngineBase.windowSize) {
        buffer.clear();
      }
    }
  }

  void _triggerPrediction(int machineId, List<SensorData> buffer) {
    if (buffer.isEmpty) return;

    try {
      final Prediction prediction = _generatePrediction(machineId, buffer);
      _savePrediction(prediction);
    } catch (e, stackTrace) {
      print("AI Engine (Web): Error during prediction trigger: $e\n$stackTrace");
    }
  }

  /// Sends the generated prediction object to the backend via the PredictionService.
  Future<void> _savePrediction(Prediction prediction) async {
    try {
      await _predictionService.createPrediction(prediction);
      print("--> (Web) Prediction successfully saved to server for machine ${prediction.machineId}.");
    } catch (e) {
      print("--> (Web) FAILED to save prediction to server: $e");
    }
  }

  /// The core "AI" logic that analyzes a buffer of sensor data to create a prediction.
  Prediction _generatePrediction(int machineId, List<SensorData> buffer) {
    final vibrationXValues = buffer.map((d) => d.vibrationX).toList();
    final vibrationYValues = buffer.map((d) => d.vibrationY).toList();
    final loadValues = buffer.map((d) => d.loadValue).toList();

    final vibXMean = vibrationXValues.reduce((a, b) => a + b) / vibrationXValues.length;
    final vibYMean = vibrationYValues.reduce((a, b) => a + b) / vibrationYValues.length;
    final loadMean = loadValues.reduce((a, b) => a + b) / loadValues.length;
    final vibXVar = vibrationXValues.map((v) => pow(v - vibXMean, 2)).reduce((a, b) => a + b) / vibrationXValues.length;
    final vibYVar = vibrationYValues.map((v) => pow(v - vibYMean, 2)).reduce((a, b) => a + b) / vibrationYValues.length;

    final double anomalyScore = (vibXMean - 50).abs() + (vibYMean - 50).abs() + (loadMean - 70).abs() + (vibXVar > 100 ? 20 : 0) + (vibYVar > 100 ? 20 : 0);

    String faultType;
    double confidence;
    double rul;

    if (anomalyScore < 30) {
      faultType = getLabelForIndex(2); // No fault
      confidence = 0.95 + Random().nextDouble() * 0.05;
      rul = 10000 + Random().nextDouble() * 2000;
    } else if (anomalyScore < 60) {
      faultType = (vibXVar > vibYVar) ? getLabelForIndex(0) : getLabelForIndex(4); // eccentricity vs surface defect
      confidence = 0.85 + Random().nextDouble() * 0.1;
      rul = 5000 + Random().nextDouble() * 2000;
    } else {
      if (loadMean > 90) {
        faultType = getLabelForIndex(3); // Root crack
      } else if (vibXVar > 150 || vibYVar > 150) {
        faultType = getLabelForIndex(5); // chipped tooth
      } else {
        faultType = getLabelForIndex(1); // missing tooth
      }
      confidence = 0.75 + Random().nextDouble() * 0.15;
      rul = 2000 + Random().nextDouble() * 1000;
    }

    return Prediction(
      id: 0,
      createdAt: DateTime.now(),
      isActive: true,
      updatedAt: DateTime.now(),
      confidence: confidence,
      faultType: faultType,
      predictedRULHours: rul,
      machineId: machineId,
    );
  }
}