import 'package:dio/dio.dart';
import 'package:maintenance_platform_frontend/model/Failure.dart';


class AlertService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/'));

  Future<List<Failure>> fetchLatestAlertes({int limit = 5}) async {
    final response = await _dio.get('latest/alerts', queryParameters: {'limit': limit});

    return (response.data as List)
        .map((json) => Failure.fromJson(json))
        .toList();
  }
}
