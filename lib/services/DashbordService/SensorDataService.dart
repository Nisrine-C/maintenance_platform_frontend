import 'package:dio/dio.dart';
import 'package:maintenance_platform_frontend/model/HistogramBin.dart';
import 'package:maintenance_platform_frontend/model/VibrationTrend.dart';
import 'package:maintenance_platform_frontend/services/DashbordService/dio_helper.dart';


class SensorService {
  final Dio _dio = DioHelper.dio;

  Future<List<VibrationTrend>> getVibrationTrends(int machineId) async {
    final response = await _dio.get('/trends', queryParameters: {'machineId': machineId});
    return (response.data as List).map((e) => VibrationTrend.fromJson(e)).toList();
  }

  Future<List<HistogramBin>> getHistogram(int machineId, {double binSize = 0.2}) async {
    final response = await _dio.get('/histogram', queryParameters: {
      'machineId': machineId,
      'binSize': binSize
    });
    return (response.data as List).map((e) => HistogramBin.fromJson(e)).toList();
  }
}
