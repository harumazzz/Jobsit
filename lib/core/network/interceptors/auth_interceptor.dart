import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
Interceptor authInterceptor(Ref ref) {
  return const AuthInterceptor();
}

class AuthInterceptor extends Interceptor {
  const AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    // TODO(self): add token
    // options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var message = err.message;
    if (err.response != null && err.response?.data != null) {
      if (err.response!.data is Map<String, dynamic>) {
        final responseData = err.response!.data as Map<String, dynamic>;
        if (responseData.containsKey('message') && responseData['message'] is String) {
          final serverMessage = responseData['message'] as String;
          if (serverMessage.isNotEmpty) {
            message = serverMessage;
          }
        }
      }
    }
    final error = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      message: message,
      error: err.error,
      stackTrace: err.stackTrace,
    );
    handler.next(error);
  }
}
