import 'package:dio/dio.dart';
import 'package:maintenance_platform_frontend/model/MachineGlobalStatus.dart';

class MachineService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8087', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<MachineStatusModel> fetchGlobalStats() async {
    try {
      final response = await _dio.get('/api/stats/global');

      if (response.statusCode == 200) {
        return MachineStatusModel.fromJson(response.data);
      } else {
        throw Exception('Erreur lors du chargement des statistiques');
      }
    } on DioException catch (e) {
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
