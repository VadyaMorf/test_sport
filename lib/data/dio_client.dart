
import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;
  final String baseUrl;
  DioClient({required this.baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

  Future<Response?> executeQuery({
    required String resourceURL,
    required String method,
    Map<String, dynamic>? body,
    String? contentType,
  }) async {
    try {
      final currentBaseUrl =  baseUrl;
      final headers = <String, String>{};
      if (contentType != null) {
        headers['Content-Type'] = contentType;
      }

      final options = Options(method: method, headers: headers);

      var requestBody = body;

      final response = await dio.request(
        currentBaseUrl + resourceURL,
        data: requestBody,
        options: options,
      );

      return response;
    } catch (e) {
      return null;
    }
  }
}
