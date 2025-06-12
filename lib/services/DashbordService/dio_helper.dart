import 'package:dio/dio.dart';

class DioHelper {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8087/api', 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Dio get dio => _dio;
}
