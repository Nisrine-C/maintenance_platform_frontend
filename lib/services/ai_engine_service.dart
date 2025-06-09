import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// Import your models. Adjust paths if needed.
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';

// Import the ONNX runtime
import 'package:onnxruntime/onnxruntime.dart';

class AiEngineService {
  // --- ONNX Model Runner ---
  late OrtSession _classificationSession;
  late OrtSession _rulSession;
  final List<String> _featureNames = [
    'sensor1_mean', 'sensor1_std', 'sensor1_rms', 'sensor2_mean', 'sensor2_std', 'sensor2_rms',
    'speedSet', 'load_value'
  ];
  final Map<int, String> _labelMap = {
    0: "eccentricity", 1: "missing tooth", 2: "No fault",
    3: "Root crack", 4: "surface defect", 5: "chipped tooth"
  };

  // --- Data Processing ---
  static const int windowSize = 5000;
  // A map to hold data buffers, one for each machine
  final Map<int, List<SensorData>> _dataBuffers = {};

  /// This is the main startup method. It loads models and starts the simulation.
  Future<void> initializeAndRun() async {
    print("AI Engine: Initializing...");
    await _loadModels();
    _startSimulatedDataStreams();
    print("AI Engine: Running and processing data streams...");
  }

  Future<void> _loadModels() async {
    final sessionOptions = OrtSessionOptions();
    final clsModelBytes = await rootBundle.load('assets/models/classification_model.onnx');
    final rulModelBytes = await rootBundle.load('assets/models/rul_model.onnx');

    // 2. Create the session from the buffer (the raw bytes)
    _classificationSession = OrtSession.fromBuffer(clsModelBytes.buffer.asUint8List(), sessionOptions);
    _rulSession = OrtSession.fromBuffer(rulModelBytes.buffer.asUint8List(), sessionOptions);

    print("AI Engine: ONNX models loaded successfully from buffer.");
  }

  /// In a real app, this method would be called every time you get a new reading from your API
  Future<void> _processNewReading(SensorData reading) async {
    // Initialize a buffer for this machine if it's the first time we see it
    _dataBuffers.putIfAbsent(reading.machineId, () => []);

    // Add the new reading to the correct buffer
    _dataBuffers[reading.machineId]!.add(reading);

    // If the buffer for this machine is full, process it
    if (_dataBuffers[reading.machineId]!.length >= windowSize) {
      final windowToProcess = List<SensorData>.from(_dataBuffers[reading.machineId]!);
      _dataBuffers[reading.machineId]!.clear(); // Reset buffer for this machine

      final features = _calculateFeatures(windowToProcess);
      final modelOutput = await _runPrediction(features);
      String faultType = modelOutput['fault_type'];

      if (faultType != "No fault") {
        double confidence = (modelOutput['probabilities'] as List<double>).reduce(max);
        double predictedRulCycles = modelOutput['rul'];
        double predictedRulHours = (predictedRulCycles * 0.0002) / 3600;

        final newPrediction = Prediction(
          id: DateTime.now().millisecondsSinceEpoch, // Use timestamp for unique ID
          createdAt: DateTime.now(),
          isActive: true,
          updatedAt: DateTime.now(),
          confidence: confidence,
          faultType: faultType,
          predictedRULHours: predictedRulHours,
          machineId: reading.machineId,
        );

        // Save the new prediction to our JSON file
        await _savePredictionToJson(newPrediction);
      }
    }
  }

  // --- Prediction Logic ---
  Future<Map<String, dynamic>> _runPrediction(List<double> inputFeatures) async {
    final runOptions = OrtRunOptions();
    final Map<String, OrtValue> inputs = {};

    for (int i = 0; i < _featureNames.length; i++) {
      final inputTensor = OrtValueTensor.createTensorWithDataList([[inputFeatures[i]]], [1, 1]);
      inputs[_featureNames[i]] = inputTensor;
    }

    final clsOutputs = await _classificationSession.run(runOptions, inputs);
    final rulOutputs = await _rulSession.run(runOptions, inputs);

    final predictedLabel = int.parse(clsOutputs[0]!.value.toString());
    final probabilitiesDict = (clsOutputs[1]!.value as List<Map>)[0];
    final probabilities = [for (int i = 0; i < _labelMap.length; i++) probabilitiesDict[i]];
    final predictedRul = (rulOutputs[0]!.value as List<List<double>>)[0][0];

    inputs.values.forEach((v) => v.release());
    clsOutputs.forEach((e) => e?.release());
    rulOutputs.forEach((e) => e?.release());

    return {
      'fault_type': _labelMap[predictedLabel] ?? "Unknown Fault",
      'probabilities': probabilities,
      'rul': predictedRul,
    };
  }

  // --- Feature Calculation Logic (self-contained, no packages needed) ---
  List<double> _calculateFeatures(List<SensorData> window) {
    final xValues = window.map((d) => d.vibrationX).toList();
    final yValues = window.map((d) => d.vibrationY).toList();
    double _mean(List<double> v) => v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;
    double _rms(List<double> v) => v.isEmpty ? 0 : sqrt(v.map((i) => i * i).reduce((a, b) => a + b) / v.length);
    double _stdDev(List<double> v, double mean) => v.length < 2 ? 0 : sqrt(v.map((i) => pow(i - mean, 2)).reduce((a, b) => a + b) / (v.length - 1));

    final xMean = _mean(xValues); final yMean = _mean(yValues);
    return [
      xMean, _stdDev(xValues, xMean), _rms(xValues),
      yMean, _stdDev(yValues, yMean), _rms(yValues),
      window.first.speedSet, window.first.loadValue
    ];
  }

  // --- File Saving Logic ---
  Future<void> _savePredictionToJson(Prediction prediction) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/predictions.json');

      List<dynamic> predictionsJson = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          predictionsJson = jsonDecode(content) as List<dynamic>;
        }
      }

      // We need a way to convert our Prediction object to a Map for JSON encoding.
      // You should add a `toJson()` method to your Prediction model.
      // For now, we'll create the map manually here.
      final predictionMap = {
        'id': prediction.id,
        'createdAt': prediction.createdAt.toIso8601String(),
        'isActive': prediction.isActive,
        'updatedAt': prediction.updatedAt.toIso8601String(),
        'confidence': prediction.confidence,
        'faultType': prediction.faultType,
        'predictedRULHours': prediction.predictedRULHours,
        'machineId': prediction.machineId,
      };

      predictionsJson.add(predictionMap);

      await file.writeAsString(jsonEncode(predictionsJson));
      print('AI Engine: Saved prediction for machine #${prediction.machineId} to predictions.json');
    } catch (e) {
      print('AI Engine: Error saving prediction to file: $e');
    }
  }

  // --- Data Simulation (for testing purposes) ---
  void _startSimulatedDataStreams() {
    // Simulate streams for 3 machines
    for (int machineId in [1, 2, 3]) {
      Stream.periodic(const Duration(milliseconds: 10), (i) {
        return SensorData(
          id: i, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(),
          loadValue: 50.0 + (machineId * 5),
          speedSet: 1000.0 - (machineId * 100),
          vibrationX: 2.5 + (sin(i / (100.0 * machineId)) * 0.2), // More variation
          vibrationY: 2.4 + (cos(i / (150.0 * machineId)) * 0.2),
          machineId: machineId,
        );
      }).listen((sensorData) {
        _processNewReading(sensorData);
      });
    }
  }
}