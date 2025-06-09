import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

// Import your models.
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';

// Import the ONNX runtime
import 'package:onnxruntime/onnxruntime.dart';


class AiEngineService {
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
  bool _isSavingToFile = false;

  static const int windowSize = 5000;
  final Map<int, List<SensorData>> _dataBuffers = {};

  Future<void> initializeAndRun() async {
    print("AI Engine: Initializing...");
    await _loadModels();
    _startSimulatedDataStreams();
    print("AI Engine: Running and processing data streams...");
  }

  Future<void> _loadModels() async {
    final sessionOptions = OrtSessionOptions();
    // Using your specific asset path
    final clsModelBytes = await rootBundle.load('assets/models/classification_model.onnx');
    final rulModelBytes = await rootBundle.load('assets/models/rul_model.onnx');

    _classificationSession = OrtSession.fromBuffer(clsModelBytes.buffer.asUint8List(), sessionOptions);
    _rulSession = OrtSession.fromBuffer(rulModelBytes.buffer.asUint8List(), sessionOptions);
    print("AI Engine: ONNX models loaded successfully from buffer.");
  }

  Future<void> _processNewReading(SensorData reading) async {
    try {
      _dataBuffers.putIfAbsent(reading.machineId, () => []);
      _dataBuffers[reading.machineId]!.add(reading);

      if (_dataBuffers[reading.machineId]!.length >= windowSize) {
        final windowToProcess = List<SensorData>.from(_dataBuffers[reading.machineId]!);
        _dataBuffers[reading.machineId]!.clear();

        final features = _calculateFeatures(windowToProcess);
        final modelOutput = await _runPrediction(features);
        String faultType = modelOutput['fault_type'];

        if (faultType != "No fault") {
          double confidence = (modelOutput['probabilities'] as List<double>).reduce(max);
          double predictedRulCycles = modelOutput['rul'];
          double predictedRulHours = (predictedRulCycles * 0.0002) / 3600;

          final newPrediction = Prediction(
            id: DateTime.now().millisecondsSinceEpoch,
            createdAt: DateTime.now(),
            isActive: true,
            updatedAt: DateTime.now(),
            confidence: confidence,
            faultType: faultType,
            predictedRULHours: predictedRulHours,
            machineId: reading.machineId,
          );
          await _savePredictionToJson(newPrediction);
        }
      }
    } catch (e, stackTrace) {
      print('AI ENGINE PROCESSING FAILED (Machine #${reading.machineId})');
      print(e);
      print(stackTrace);

    }
  }
  // lib/services/ai_engine_service.dart

// ... inside the AiEngineService class ...
// lib/services/ai_engine_service.dart

// ... inside the AiEngineService class ...

  // lib/services/ai_engine_service.dart

// ... inside the AiEngineService class ...

  Future<Map<String, dynamic>> _runPrediction(List<double> inputFeatures) async {
    final runOptions = OrtRunOptions();
    final Map<String, OrtValue> inputs = {};

    // Create the 8 named inputs as 32-bit float tensors
    for (int i = 0; i < _featureNames.length; i++) {
      final float32List = Float32List.fromList([inputFeatures[i]]);
      final inputTensor = OrtValueTensor.createTensorWithDataList([float32List], [1, 1]);
      inputs[_featureNames[i]] = inputTensor;
    }

    // Run both models
    final clsOutputs = await _classificationSession.run(runOptions, inputs);
    final rulOutputs = await _rulSession.run(runOptions, inputs);

    // --- THE OFFICIAL, DOCUMENTED, AND CORRECT OUTPUT HANDLING ---

    // 1. Get the predicted label
    final predictedLabel = (clsOutputs[0]!.value as List).first as int;

    // 2. Get the OrtValueMap which is a WRAPPER around the actual map
    final probabilitiesOrtMap = (clsOutputs[1]!.value as List<OrtValueMap>).first;

    // 3. THIS IS THE CORRECT API USAGE: Access the .value property to get the real Dart Map
    final Map<int, double> probabilitiesMap =
    Map.from(probabilitiesOrtMap.value as Map);

    // 4. Create the final, ordered list of probabilities from the Dart Map
    final List<double> probabilities = List.generate(
      _labelMap.length,
          (index) => probabilitiesMap[index] ?? 0.0, // Use 0.0 as a fallback
    );

    // 5. Get the RUL
    final predictedRul = (rulOutputs[0]!.value as List<List<double>>).first.first;

    // --- END OF FIX ---

    // Clean up all remaining memory
    inputs.values.forEach((v) => v.release());
    clsOutputs.forEach((e) => e?.release());
    rulOutputs.forEach((e) => e?.release());
    // The OrtValueMap itself must also be released
    probabilitiesOrtMap.release();

    return {
      'fault_type': _labelMap[predictedLabel] ?? "Unknown Fault",
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

  Future<void> _savePredictionToJson(Prediction prediction) async {
    // Wait if another save operation is already in progress.
    // This is our waiting room.
    while (_isSavingToFile) {
      await Future.delayed(const Duration(milliseconds: 30));
    }

    try {
      // Lock the file for writing
      _isSavingToFile = true;

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/predictions.json');

      List<dynamic> predictionsJson = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          // It's possible to read a corrupted file if a previous write failed.
          // We'll wrap the decode in its own try-catch.
          try {
            predictionsJson = jsonDecode(content) as List<dynamic>;
          } catch (e) {
            print('AI Engine: Could not decode existing JSON, starting fresh. Error: $e');
            // If the file is corrupt, we start with a fresh list.
          }
        }
      }

      final predictionMap = {
        'id': prediction.id, 'createdAt': prediction.createdAt.toIso8601String(),
        'isActive': prediction.isActive, 'updatedAt': prediction.updatedAt.toIso8601String(),
        'confidence': prediction.confidence, 'faultType': prediction.faultType,
        'predictedRULHours': prediction.predictedRULHours, 'machineId': prediction.machineId,
      };

      predictionsJson.add(predictionMap);
      await file.writeAsString(jsonEncode(predictionsJson));
      print('AI Engine: Saved prediction for machine #${prediction.machineId} to predictions.json');

    } catch (e) {
      print('AI Engine: Error during file save operation: $e');
    } finally {
      // CRUCIAL: Always unlock the file when we're done, even if an error occurred.
      _isSavingToFile = false;
    }
  }


  void _startSimulatedDataStreams() {
    for (int machineId in [1, 2, 3]) {
      Stream.periodic(const Duration(milliseconds: 10), (i) {
        return SensorData(
          id: i, createdAt: DateTime.now(), isActive: true, updatedAt: DateTime.now(),
          loadValue: 50.0 + (machineId * 5),
          speedSet: 1000.0 - (machineId * 100),
          vibrationX: 2.5 + (sin(i / (100.0 * machineId)) * 0.2),
          vibrationY: 2.4 + (cos(i / (150.0 * machineId)) * 0.2),
          machineId: machineId,
        );
      }).listen((sensorData) {
        _processNewReading(sensorData);
      });
    }
  }
}