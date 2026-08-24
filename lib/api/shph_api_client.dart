import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '/api/api_config.dart';
import '/api/shph_api_exception.dart';
import '/api/shph_token_storage.dart';
import '/demo/demo_interceptor.dart';
import '/demo/demo_mode.dart';
import '/services/logging_service.dart';

/// Central Dio HTTP client for the SHPH REST API (OpenAPI spec).
class ShphApiClient {
  ShphApiClient._();

  static final ShphApiClient instance = ShphApiClient._();

  Dio? _dio;
  bool _isRefreshing = false;

  Dio get dio {
    final client = _dio;
    if (client == null) {
      throw StateError(
        'ShphApiClient not initialized. Call ShphApiClient.initialize() first.',
      );
    }
    return client;
  }

  static Future<void> initialize() async {
    final self = instance;
    self._dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (kDemoMode) {
      self._dio!.interceptors.add(DemoInterceptor());
    }

    self._dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await ShphTokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldRefresh = error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true;

          if (!shouldRefresh) {
            handler.next(error);
            return;
          }

          try {
            final refreshed = await self._refreshAccessToken();
            if (!refreshed) {
              handler.next(error);
              return;
            }

            final token = await ShphTokenStorage.getAccessToken();
            final requestOptions = error.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $token';
            requestOptions.extra['retried'] = true;

            final response = await self._dio!.fetch(requestOptions);
            handler.resolve(response);
          } catch (_) {
            handler.next(error);
          }
        },
      ),
    );

    if (kDebugMode) {
      self._dio!.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (message) =>
              LoggingService.debug(message.toString(), tag: 'ShphApiClient'),
        ),
      );
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await ShphTokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }
      final sessionId = await ShphTokenStorage.getSessionId();

      final response = await Dio(
        BaseOptions(baseUrl: ApiConfig.baseUrl),
      ).post(
        '/api/auth/token/refresh/',
        data: {'refresh': refreshToken, 'session_id': sessionId},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final access = data['access'] as String?;
        final refresh = data['refresh'] as String?;
        final sessionId = data['session_id'] as String?;
        if (access != null) {
          await ShphTokenStorage.saveTokens(
            accessToken: access,
            refreshToken: refresh,
            sessionId: sessionId,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      LoggingService.error('Token refresh failed: $e', tag: 'ShphApiClient');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ShphApiException.fromDio(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ShphApiException.fromDio(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ShphApiException.fromDio(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ShphApiException.fromDio(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ShphApiException.fromDio(e);
    }
  }
}
