import 'package:flutter/foundation.dart';
import '../model/SensorData.model.dart';
import '../model/Prediction.model.dart';
import 'ai_engine_base.dart';
import 'ai_engine_service_web.dart';
import 'ai_engine_service_native.dart';

/// This is the main service class that delegates to the appropriate implementation
/// based on the platform (web or native).
class AiEngineService implements AiEngineBase {
  static final AiEngineService _instance = AiEngineService._internal();
  late final AiEngineBase _implementation;

  factory AiEngineService() {
    return _instance;
  }

  AiEngineService._internal() {
    _implementation = kIsWeb ? AiEngineServiceWeb() : AiEngineServiceNative();
  }

  @override
  Future<void> initializeAndRun() async {
    await _implementation.initializeAndRun();
  }

  @override
  Future<void> processNewReading(SensorData reading) async {
    await _implementation.processNewReading(reading);
  }

  @override
  void startSimulatedDataStreams() {
    _implementation.startSimulatedDataStreams();
  }

  @override
  String getLabelForIndex(int index) {
    return _implementation.getLabelForIndex(index);
  }
}
