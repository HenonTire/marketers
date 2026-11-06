
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:marketers/service/api_config.dart';
import 'package:marketers/service/auth_session_store.dart';

enum ApiFailureKind {
  network,
  unauthorized,
  server,
  response,
}

class ApiFailure implements Exception {
  const ApiFailure(
    this.kind,
    this.message, {
    this.statusCode,
  });

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                sendTimeout: const Duration(seconds: 20),

                // Explicitly define Dio's important boolean options.
                followRedirects: true,
                receiveDataWhenStatusError: true,
                persistentConnection: true,

                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                  'ngrok-skip-browser-warning': 'true',
                },
              ),
            ) {
    _dio.interceptors.add(
      _AuthenticationInterceptor(_dio),
    );
  }

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _send(
      () => _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      ),
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
  }) {
    return _send(
      () => _dio.post<dynamic>(
        path,
        data: data,
      ),
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
  }) {
    return _send(
      () => _dio.patch<dynamic>(
        path,
        data: data,
      ),
    );
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    await AuthSessionStore.restore();

    try {
      final response = await request();

      debugPrint(
        'API SUCCESS\n'
        'Method: ${response.requestOptions.method}\n'
        'URL: ${response.requestOptions.uri}\n'
        'Status: ${response.statusCode}',
      );

      return response;
    } on DioException catch (error, stackTrace) {
      final failure = _failureFrom(error);

      debugPrint(
        '════════════════════════════════════\n'
        'API FAILURE\n'
        'Method: ${error.requestOptions.method}\n'
        'URL: ${error.requestOptions.uri}\n'
        'Status: ${error.response?.statusCode ?? 'none'}\n'
        'Type: ${error.type}\n'
        'Message: ${error.message ?? 'none'}\n'
        'Error: ${error.error ?? 'none'}\n'
        'Response: ${error.response?.data ?? 'none'}\n'
        'Failure: ${failure.message}\n'
        '════════════════════════════════════',
      );

      debugPrintStack(
        label: 'DIO STACK TRACE',
        stackTrace: stackTrace,
      );

      throw failure;
    } catch (error, stackTrace) {
      debugPrint(
        '════════════════════════════════════\n'
        'API UNKNOWN ERROR\n'
        'Error: $error\n'
        '════════════════════════════════════',
      );

      debugPrintStack(
        label: 'UNKNOWN ERROR STACK TRACE',
        stackTrace: stackTrace,
      );

      rethrow;
    }
  }

  static ApiFailure _failureFrom(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;

    String message;

    if (data is Map) {
      final detail = data['detail'];
      final serverMessage = data['message'];
      final errorMessage = data['error'];

      if (detail != null) {
        message = detail.toString();
      } else if (serverMessage != null) {
        message = serverMessage.toString();
      } else if (errorMessage != null) {
        message = errorMessage.toString();
      } else {
        message = _messageForError(error, status);
      }
    } else {
      message = _messageForError(error, status);
    }

    if (status == 401) {
      return ApiFailure(
        ApiFailureKind.unauthorized,
        message,
        statusCode: status,
      );
    }

    if (status != null && status >= 500) {
      return ApiFailure(
        ApiFailureKind.server,
        message,
        statusCode: status,
      );
    }

    if (_isNetworkError(error)) {
      return ApiFailure(
        ApiFailureKind.network,
        message,
        statusCode: status,
      );
    }

    return ApiFailure(
      ApiFailureKind.response,
      message,
      statusCode: status,
    );
  }

  static bool _isNetworkError(DioException error) {
    return error.error is SocketException ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  static String _messageForError(
    DioException error,
    int? status,
  ) {
    if (status == 401) {
      return 'Your session has expired. Please sign in again.';
    }

    if (status != null && status >= 500) {
      return 'The server could not complete the request.';
    }

    if (_isNetworkError(error)) {
      return 'Could not reach the backend. Check your connection and backend URL.';
    }

    if (error.type == DioExceptionType.badResponse) {
      return 'The backend returned an invalid response.';
    }

    return 'Request failed. Please try again.';
  }
}

class _AuthenticationInterceptor extends Interceptor {
  _AuthenticationInterceptor(this._dio);

  final Dio _dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    await AuthSessionStore.restore();

    final isRefresh = options.path == '/auth/refresh/';

    if (isRefresh) {
      final cookie = AuthSessionStore.refreshCookie;

      if (cookie != null && cookie.isNotEmpty) {
        options.headers['Cookie'] = cookie;
      }
    } else if (options.extra['skipAuth'] != true) {
      final token = AuthSessionStore.accessToken;

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final cookie = response.headers.value('set-cookie');

    if (cookie != null && cookie.isNotEmpty) {
      await AuthSessionStore.saveRefreshCookieHeader(cookie);
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;

    final shouldRefresh =
        error.response?.statusCode == 401 &&
        request.path != '/auth/refresh/' &&
        request.extra['retriedAfterRefresh'] != true;

    if (!shouldRefresh) {
      handler.next(error);
      return;
    }

    try {
      final response = await _dio.post<dynamic>(
        '/auth/refresh/',
        options: Options(
          extra: const {
            'skipAuth': true,
          },
        ),
      );

      final data = response.data;

      final accessToken =
          data is Map ? data['access']?.toString() ?? '' : '';

      if (accessToken.isEmpty) {
        await AuthSessionStore.clear();
        handler.next(error);
        return;
      }

      await AuthSessionStore.saveAccessToken(accessToken);

      request.extra['retriedAfterRefresh'] = true;
      request.headers['Authorization'] = 'Bearer $accessToken';

      final retried = await _dio.fetch<dynamic>(request);

      handler.resolve(retried);
    } catch (_) {
      await AuthSessionStore.clear();
      handler.next(error);
    }
  }
}

