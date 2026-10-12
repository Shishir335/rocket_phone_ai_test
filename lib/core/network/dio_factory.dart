import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'mock_contacts_interceptor.dart';

class DioFactory {
  static Dio createDio(MockContactsInterceptor mockInterceptor) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(mockInterceptor);
    return dio;
  }
}
