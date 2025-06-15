import 'package:dio/dio.dart';
import 'package:maintenance_platform_frontend/model/Failure.dart';

class AlertService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8087/api/'));

  Future<List<Failure>> fetchLatestAlertes() async {
    try {
      final response = await _dio.get('latest/alerts');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Failure.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Erreur Dio : ${e.message}');
      throw Exception('Erreur réseau ou API');
    } catch (e) {
      print('Erreur inconnue : $e');
      throw Exception('Erreur inattendue');
    }
  }
}
