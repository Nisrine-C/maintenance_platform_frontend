import 'dart:async';
import 'dart:math';
import 'dart:typed_data'; // Correct import for Float32List
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle; // For loading assets
import 'package:onnxruntime/onnxruntime.dart';

// Your existing project imports
import 'package:maintenance_platform_frontend/model/Failure.model.dart';
import 'package:maintenance_platform_frontend/services/failure_service.dart';
import 'package:maintenance_platform_frontend/services/prediction_service.dart';
import 'package:maintenance_platform_frontend/services/sensor_data_service.dart';
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';

class AiEngineServiceNative extends AiEngineBase {
  // --- STATE MANAGEMENT (from your existing code) ---
  final Map<int, List<SensorData>> _dataBuffers = {};
  final Set<int> _processedReadingIds = {};

  // --- SERVICE DEPENDENCIES (from your existing code) ---
  final SensorDataService _sensorDataService = SensorDataService();
  final PredictionService _predictionService = PredictionService();
  final FailureService _failureService = FailureService();

  // --- LIVE ONNX MODEL STATE ---
  late OrtSession _classificationSession;
  late OrtSession _rulSession;
  bool _modelsLoaded = false;
  final List<String> _featureNames = [
    'sensor1_mean', 'sensor1_std', 'sensor1_rms', 'sensor2_mean', 'sensor2_std', 'sensor2_rms',
    'speedSet', 'load_value'
  ];

  @override
  Future<void> initializeAndRun() async {
    print("AI Engine (Native): Initializing...");
    await _loadModels(); // Load the models at startup
    _startDataProcessingLoop();
    print("AI Engine (Native): Initialization complete. Starting data polling...");
  }

  /// Loads the ONNX models from assets into memory.
  Future<void> _loadModels() async {
    try {
      final sessionOptions = OrtSessionOptions();
      // Ensure your .onnx files are in the root 'assets/' folder
      final clsModelBytes = await rootBundle.load('assets/models/classification_model.onnx');
      final rulModelBytes = await rootBundle.load('assets/models/rul_model.onnx');

      _classificationSession = OrtSession.fromBuffer(clsModelBytes.buffer.asUint8List(), sessionOptions);
      _rulSession = OrtSession.fromBuffer(rulModelBytes.buffer.asUint8List(), sessionOptions);
      _modelsLoaded = true;
      print("AI Engine (Native): ONNX models loaded successfully.");
    } catch (e) {
      print("AI Engine (Native) CRITICAL ERROR: Failed to load ONNX models: $e");
    }
  }

  // This method remains unchanged from your code.
  void _startDataProcessingLoop() {
    Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (!_modelsLoaded) {
        debugPrint("AI Engine (Native): Models not loaded yet, skipping poll.");
        return;
      }
      debugPrint("AI Engine (Native): Polling for sensor data...");
      try {
        final List<SensorData> allReadings = await _sensorDataService.getSensorDatas();
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

  // This method remains unchanged from your code.
  @override
  Future<void> processNewReading(SensorData reading) async {
    _dataBuffers.putIfAbsent(reading.machineId, () => []);
    final buffer = _dataBuffers[reading.machineId]!;
    buffer.add(reading);
    debugPrint("AI Engine: Added reading for machine ${reading.machineId}. Buffer size: ${buffer.length}");

    if (buffer.length >= AiEngineBase.windowSize) {
      debugPrint("AI Engine: Buffer full for machine ${reading.machineId}. Triggering prediction.");
      final analysisSlice = buffer.sublist(buffer.length - AiEngineBase.windowSize);
      await _triggerPrediction(reading.machineId, analysisSlice, DateTime.now());
      buffer.removeAt(0); // Slide the window
    }
  }

  // This method is now async to handle the prediction logic.
  Future<void> _triggerPrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) async {
    if (buffer.isEmpty || !_modelsLoaded) return;
    try {
      final Prediction? prediction = await _generatePrediction(machineId, buffer, predictionTime);

      if (prediction != null) {
        _savePrediction(prediction);
        print(prediction.toJson());
        if (prediction.predictedRULHours <1) {
          print("--> (Native) RUL is <= 0. Generating a failure record for machine $machineId.");
          final Failure failure = Failure(
            createdAt: predictionTime, isActive: true, updatedAt: predictionTime,
            downtimeHours: 2 + Random().nextDouble() * 6,
            faultType: prediction.faultType, machineId: machineId,
          );
          _saveFailure(failure);
        }
      }
    } catch (e, stackTrace) {
      print("AI Engine (Native): Error during prediction trigger: $e\n$stackTrace");
    }
  }

  // --- REWRITTEN AI LOGIC ---

  /// REPLACED: This now uses the real ONNX models instead of placeholder rules.
  /// It returns a nullable Prediction, as "No fault" results are ignored.
  Future<Prediction?> _generatePrediction(int machineId, List<SensorData> buffer, DateTime predictionTime) async {
    // 1. Calculate the 8 features the model expects.
    final features = _calculateFeatures(buffer);

    // 2. Run the ONNX models to get the raw output.
    final modelOutput = await _runPrediction(features);

    // 3. Create the final Prediction object from the model's output.
    String faultType = modelOutput['fault_type']!;

    // IMPORTANT: If there is no fault, we don't generate a prediction record.
    if (faultType == "No fault") {
      print("AI Engine (Native): Machine #$machineId is healthy (No fault detected).");
      return null;
    }

    double confidence = (modelOutput['probabilities'] as List<double>).reduce(max);
    double predictedRulCycles = modelOutput['rul']!;
    // Convert RUL from model's "cycles" output to hours.
    // This conversion factor (0.0002) comes from your original Python script.
    double predictedRulHours = (predictedRulCycles * 0.0002) / 3600;

    return Prediction(
      createdAt: predictionTime, isActive: true, updatedAt: predictionTime,
      confidence: confidence.clamp(0.0, 1.0),
      faultType: faultType,
      predictedRULHours: max(0, predictedRulHours), // Ensure RUL isn't negative
      machineId: machineId,
    );
  }

  /// The core ONNX inference logic for running the models.
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

    // The probabilities output is a List containing a special OrtValueMap.
    final ortValueMap = (clsOutputs[1]!.value as List<OrtValueMap>)[0];
    // The .value property of the OrtValueMap is the actual Map<int, double> we need.
    final probabilitiesDict = ortValueMap.value;
    // --- END OF FIX ---

    final probabilities = [for (int i = 0; i < 6; i++) probabilitiesDict[i] as double];
    final predictedRul = (rulOutputs[0]!.value as List<List<double>>)[0][0];
    // IMPORTANT: Release memory used by the tensors
    inputs.values.forEach((v) => v.release());
    clsOutputs.forEach((e) => e?.release());
    rulOutputs.forEach((e) => e?.release());

    return {
      'fault_type': getLabelForIndex(predictedLabel),
      'probabilities': probabilities,
      'rul': predictedRul,
    };
  }

  /// The feature calculation logic from your original Python script.
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

  // These methods remain unchanged from your code.
  Future<void> _savePrediction(Prediction prediction) async {
    try {
      await _predictionService.createPrediction(prediction);
      print("--> (Native) Prediction saved to server for machine ${prediction.machineId}. Fault: ${prediction.faultType}");
    } catch (e) {
      print("--> (Native) FAILED to save prediction to server: $e");
    }
  }

  Future<void> _saveFailure(Failure failure) async {
    try {
      await _failureService.createFailure(failure);
      print("--> (Native) Failure record saved to server for machine ${failure.machineId}.");
    } catch (e) {
      print("--> (Native) FAILED to save failure record to server: $e");
    }
  }
}