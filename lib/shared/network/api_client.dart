import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:stably_app/shared/config/app_environment.dart';
import 'package:stably_app/shared/network/api_exception.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      PrettyDioLogger(
        requestBody: false,
        responseBody: false,
      ),
    );
  }

  return dio;
});

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );

      final body = response.data;
      if (body == null) {
        throw ApiException('Empty response body');
      }

      if (body['ok'] == false) {
        final error = body['error'];
        throw ApiException(
          error is Map<String, dynamic>
              ? (error['message'] as String? ?? 'Request failed')
              : 'Request failed',
          code: error is Map<String, dynamic> ? error['code'] as String? : null,
          statusCode: response.statusCode,
        );
      }

      return body;
    } on DioException catch (error) {
      final responseBody = error.response?.data;
      if (responseBody is Map<String, dynamic> && responseBody['error'] is Map<String, dynamic>) {
        final apiError = responseBody['error'] as Map<String, dynamic>;
        throw ApiException(
          apiError['message'] as String? ?? error.message ?? 'Request failed',
          code: apiError['code'] as String?,
          statusCode: error.response?.statusCode,
        );
      }

      throw ApiException(
        error.message ?? 'Network request failed',
        statusCode: error.response?.statusCode,
      );
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
