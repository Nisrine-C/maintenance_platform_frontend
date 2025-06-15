import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:maintenance_platform_frontend/model/Failure.model.dart';
import 'package:maintenance_platform_frontend/services/failure_service.dart';
import 'package:maintenance_platform_frontend/services/prediction_service.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';

import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';

class AiEngineServiceNative extends AiEngineBase {
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
  /// Service to send new failures to the backend.
  final FailureService _failureService = FailureService();

  @override
  Future<void> initializeAndRun() async {
    print("AI Engine (Native): Initializing and starting data polling...");
    _startDataProcessingLoop();
  }

  // Starts a periodic timer to poll the backend for sensor data.
  void _startDataProcessingLoop() {
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      debugPrint("AI Engine (Native): Polling for sensor data...");
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
        print("AI Engine (Native) ERROR: Failed to fetch sensor data: $e");
      }
    });
  }

  @override
  Future<void> processNewReading(SensorData reading) async {
    // 1. SETUP & LOGGING
    if (!_dataBuffers.containsKey(reading.machineId)) {
      _dataBuffers[reading.machineId] = [];
    }
    final buffer = _dataBuffers[reading.machineId]!;
    final windowSize = AiEngineBase.windowSize;

    // 2. ADD NEW DATA
    buffer.add(reading);
    debugPrint("AI Engine: Added reading for machine ${reading.machineId}. Buffer size now: ${buffer.length}");

    // 3. THE TRIGGER CONDITION (SIMPLE AND CLEAR)
    // We only proceed if the buffer has AT LEAST enough data for one window.
    if (buffer.length >= windowSize) {
      debugPrint("AI Engine: Buffer is full (${buffer.length}/$windowSize). Triggering prediction.");

      // A. Perform the prediction on a SLICE of the most recent data.
      // This ensures we always use exactly 'windowSize' items.
      final analysisSlice = buffer.sublist(buffer.length - windowSize);
      final now = DateTime.now();
      _triggerPrediction(reading.machineId, analysisSlice, now);
      _lastPredictionTime[reading.machineId] = now;

      // B. Trim the buffer to prevent it from growing indefinitely.
      // This is a more robust sliding window. It removes the oldest reading.
      buffer.removeAt(0);
      debugPrint("AI Engine: Slid window. Buffer size is now ${buffer.length}.");

    } else {
      // If the buffer is not full, we explicitly log it and do nothing else.
      debugPrint("AI Engine: Buffer filling... (${buffer.length}/$windowSize). Waiting for more data.");
    }
  }

  void _triggerPrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) {
    if (buffer.isEmpty) return;

    try {
      // 1. Generate the prediction, passing the consistent timestamp
      final Prediction prediction = _generatePrediction(machineId, buffer, predictionTime);
      _savePrediction(prediction);

      // 2. Check if the prediction indicates an immediate failure (RUL <= 0)
      if (prediction.predictedRULHours <= 0) {
        print("--> (Native) RUL is 0. Generating a failure record for machine $machineId.");
        // 3. Create a Failure object from the prediction data
        final Failure failure = Failure(
          createdAt: predictionTime,
          isActive: true,
          updatedAt: predictionTime,
          downtimeHours: 2 + Random().nextDouble() * 6, // Simulate 2-8 hours of downtime
          faultType: prediction.faultType, // Use the same fault type as the prediction
          machineId: machineId,
        );
        // 4. Save the failure record to the backend
        _saveFailure(failure);
      }
    } catch (e, stackTrace) {
      print("AI Engine (Native): Error during prediction trigger: $e\n$stackTrace");
    }
  }

  /// Sends the generated prediction object to the backend via the PredictionService.
  Future<void> _savePrediction(Prediction prediction) async {
    try {
      await _predictionService.createPrediction(prediction);
      print("--> (Native) Prediction successfully saved to server for machine ${prediction.machineId}.");
    } catch (e) {
      print("--> (Native) FAILED to save prediction to server: $e");
    }
  }

  /// Sends the generated failure object to the backend via the FailureService.
  Future<void> _saveFailure(Failure failure) async {
    try {
      await _failureService.createFailure(failure);
      print("--> (Native) Failure record successfully saved to server for machine ${failure.machineId}.");
    } catch (e) {
      print("--> (Native) FAILED to save failure record to server: $e");
    }
  }

  /// The core "AI" logic that analyzes a buffer of sensor data to create a prediction.
  Prediction _generatePrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) {
    final vibrationXValues = buffer.map((d) => d.vibrationX).toList();
    final vibrationYValues = buffer.map((d) => d.vibrationY).toList();
    final loadValues = buffer.map((d) => d.loadValue).toList();

    // Calculate statistics (mean, variance)
    final vibXMean = vibrationXValues.reduce((a, b) => a + b) / vibrationXValues.length;
    final vibYMean = vibrationYValues.reduce((a, b) => a + b) / vibrationYValues.length;
    final loadMean = loadValues.reduce((a, b) => a + b) / loadValues.length;
    final vibXVar = vibrationXValues.map((v) => pow(v - vibXMean, 2)).reduce((a, b) => a + b) / vibrationXValues.length;
    final vibYVar = vibrationYValues.map((v) => pow(v - vibYMean, 2)).reduce((a, b) => a + b) / vibrationYValues.length;

    // Generate an anomaly score based on deviations from expected norms.
    final double anomalyScore = (vibXMean - 50).abs() + (vibYMean - 50).abs() + (loadMean - 70).abs() + (vibXVar > 100 ? 20 : 0) + (vibYVar > 100 ? 20 : 0);

    String faultType;
    double confidence;
    double rul;

    // A simple rule-based system to classify faults based on the anomaly score.
    if (anomalyScore > 120) {
      // Catastrophic failure condition
      faultType = getLabelForIndex(1); // 'Missing Tooth' as a critical failure
      confidence = 0.9 + Random().nextDouble() * 0.1;
      rul = 0.0; // The machine has failed, RUL is zero.
    } else if (anomalyScore < 30) {
      faultType = getLabelForIndex(2); // No fault
      confidence = 0.95 + Random().nextDouble() * 0.05;
      rul = 10000 + Random().nextDouble() * 2000;
    } else if (anomalyScore < 60) {
      faultType = (vibXVar > vibYVar) ? getLabelForIndex(0) : getLabelForIndex(4); // eccentricity vs surface defect
      confidence = 0.85 + Random().nextDouble() * 0.1;
      rul = 5000 + Random().nextDouble() * 2000;
    } else { // anomalyScore is between 60 and 120
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

    // Create the prediction object.
    return Prediction(
      createdAt: predictionTime,
      isActive: true,
      updatedAt: predictionTime,
      confidence: confidence,
      faultType: faultType,
      predictedRULHours: rul,
      machineId: machineId,
    );
  }
}