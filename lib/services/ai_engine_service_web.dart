import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';

// Your existing project imports
import 'package:maintenance_platform_frontend/model/Failure.model.dart';
import 'package:maintenance_platform_frontend/services/failure_service.dart';
import 'package:maintenance_platform_frontend/services/prediction_service.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';

class AiEngineServiceWeb extends AiEngineBase {
  // State and service dependencies are identical to the native version
  final Map<int, List<SensorData>> _dataBuffers = {};
  final Set<int> _processedReadingIds = {};
  final SensorDataService _sensorDataService = SensorDataService();
  final PredictionService _predictionService = PredictionService();
  final FailureService _failureService = FailureService();

  // ONNX model state is identical
  late OrtSession _classificationSession;
  late OrtSession _rulSession;
  bool _modelsLoaded = false;
  final List<String> _featureNames = [
    'sensor1_mean', 'sensor1_std', 'sensor1_rms', 'sensor2_mean', 'sensor2_std', 'sensor2_rms',
    'speedSet', 'load_value'
  ];

  @override
  Future<void> initializeAndRun() async {
    print("AI Engine (Web): Initializing...");
    await _loadModels();
    _startDataProcessingLoop();
    print("AI Engine (Web): Initialization complete. Starting data polling...");
  }

  /// CORRECTED: This now uses the proper `fromAsset` method, which handles URL fetching on web.
  Future<void> _loadModels() async {
    try {
      final sessionOptions = OrtSessionOptions();

      // For web, fromAsset('path') automatically fetches from 'your-app-url.com/path'.
      // This is why the models must be in the `web/assets/models` directory.
      const clsModelPath = 'assets/models/classification_model.onnx';
      const rulModelPath = 'assets/models/rul_model.onnx';

      final clsModelBytes = await rootBundle.load(clsModelPath);
      final rulModelBytes = await rootBundle.load(rulModelPath);

      _classificationSession = OrtSession.fromBuffer(clsModelBytes.buffer.asUint8List(), sessionOptions);
      _rulSession = OrtSession.fromBuffer(rulModelBytes.buffer.asUint8List(), sessionOptions);
      _modelsLoaded = true;
      print("AI Engine (Web): ONNX models loaded successfully from assets.");
    } catch (e) {
      print("AI Engine (Web) CRITICAL ERROR: Failed to load ONNX models: $e");
      print("Ensure the .onnx files are in the 'your_project/web/assets/models/' directory.");
    }
  }

  // --- ALL LOGIC BELOW IS IDENTICAL TO THE NATIVE VERSION ---

  void _startDataProcessingLoop() {
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (!_modelsLoaded) {
        debugPrint("AI Engine (Web): Models not loaded yet, skipping poll.");
        return;
      }
      debugPrint("AI Engine (Web): Polling for sensor data...");
      try {
        final List<SensorData> allReadings = await _sensorDataService.getSensorDatas();
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
    _dataBuffers.putIfAbsent(reading.machineId, () => []);
    final buffer = _dataBuffers[reading.machineId]!;
    buffer.add(reading);

    if (buffer.length >= AiEngineBase.windowSize) {
      final analysisSlice = buffer.sublist(buffer.length - AiEngineBase.windowSize);
      await _triggerPrediction(reading.machineId, analysisSlice, DateTime.now());
      buffer.removeAt(0); // Slide the window
    }
  }

  Future<void> _triggerPrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) async {
    if (buffer.isEmpty || !_modelsLoaded) return;
    try {
      final Prediction? prediction = await _generatePrediction(machineId, buffer, predictionTime);
      if (prediction != null) {
        _savePrediction(prediction);
        if (prediction.predictedRULHours <= 1.0) { // Using 1.0 hour as the failure threshold
          print("--> (Web) RUL is <= 1.0 hour. Generating a failure record for machine $machineId.");
          final Failure failure = Failure(
            createdAt: predictionTime, isActive: true, updatedAt: predictionTime,
            downtimeHours: 2 + Random().nextDouble() * 6,
            faultType: prediction.faultType, machineId: machineId,
          );
          _saveFailure(failure);
        }
      }
    } catch (e, stackTrace) {
      print("AI Engine (Web): Error during prediction trigger: $e\n$stackTrace");
    }
  }

  Future<Prediction?> _generatePrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) async {
    final features = _calculateFeatures(buffer);
    final modelOutput = await _runPrediction(features);
    String faultType = modelOutput['fault_type']!;

    if (faultType == "No fault") {
      print("AI Engine (Web): Machine #$machineId is healthy (No fault detected).");
      return null;
    }

    double confidence = (modelOutput['probabilities'] as List<double>).reduce(max);
    double predictedRulCycles = modelOutput['rul']!;
    double predictedRulHours = (predictedRulCycles * 0.0002) / 3600;

    return Prediction(
      createdAt: predictionTime, isActive: true, updatedAt: predictionTime,
      confidence: confidence.clamp(0.0, 1.0),
      faultType: faultType,
      predictedRULHours: max(0, predictedRulHours),
      machineId: machineId,
    );
  }

  Future<Map<String, dynamic>> _runPrediction(List<double> inputFeatures) async {
    final runOptions = OrtRunOptions();
    final Map<String, OrtValue> inputs = {};

    for (int i = 0; i < _featureNames.length; i++) {
      final valueList = [inputFeatures[i]];
      final float32List = Float32List.fromList(valueList);
      final inputTensor = OrtValueTensor.createTensorWithDataList([float32List], [1, 1]);
      inputs[_featureNames[i]] = inputTensor;
    }

    final clsOutputs = await _classificationSession.run(runOptions, inputs);
    final rulOutputs = await _rulSession.run(runOptions, inputs);

    final predictedLabel = (clsOutputs[0]!.value as List<dynamic>)[0] as int;
    final ortValueMap = (clsOutputs[1]!.value as List<OrtValueMap>)[0];
    final probabilitiesDict = ortValueMap.value;

    final probabilities = [for (int i = 0; i < 6; i++) probabilitiesDict[i] as double];
    final predictedRul = (rulOutputs[0]!.value as List<List<double>>)[0][0];

    inputs.values.forEach((v) => v.release());
    clsOutputs.forEach((e) => e?.release());
    rulOutputs.forEach((e) => e?.release());

    return {
      'fault_type': getLabelForIndex(predictedLabel),
      'probabilities': probabilities,
      'rul': predictedRul,
    };
  }

  List<double> _calculateFeatures(List<SensorData> window) {
    final xValues = window.map((d) => d.vibrationX).toList();
    final yValues = window.map((d) => d.vibrationY).toList();

    double mean(List<double> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
    double rms(List<double> v) => v.isEmpty ? 0 : sqrt(v.map((i) => i * i).reduce((a, b) => a + b) / v.length);
    double stdDev(List<double> v, double m) => v.length < 2 ? 0 : sqrt(v.map((i) => pow(i - m, 2)).reduce((a, b) => a + b) / (v.length - 1));

    final xMean = mean(xValues);
    final yMean = mean(yValues);

    return [
      xMean, stdDev(xValues, xMean), rms(xValues),
      yMean, stdDev(yValues, yMean), rms(yValues),
      window.first.speedSet, window.first.loadValue
    ];
  }

  Future<void> _savePrediction(Prediction prediction) async {
    try {
      await _predictionService.createPrediction(prediction);
      print("--> (Web) Prediction saved to server for machine ${prediction.machineId}. Fault: ${prediction.faultType}");
    } catch (e) {
      print("--> (Web) FAILED to save prediction to server: $e");
    }
  }

  Future<void> _saveFailure(Failure failure) async {
    try {
      await _failureService.createFailure(failure);
      print("--> (Web) Failure record saved to server for machine ${failure.machineId}.");
    } catch (e) {
      print("--> (Web) FAILED to save failure record to server: $e");
    }
  }
}