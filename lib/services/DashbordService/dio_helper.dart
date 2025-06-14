import 'package:dio/dio.dart';

class DioHelper {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8087/api', 
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static Dio get dio => _dio;
}
