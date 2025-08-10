import 'package:dio/dio.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // Optional simple logger
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }
  static const String _baseUrl = 'https://growright.codeopia.dev';

  late final Dio _dio;
  Dio get dio => _dio;
}
