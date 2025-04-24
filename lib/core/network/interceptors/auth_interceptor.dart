import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../injection_container.dart';
import '../../services/shared_prefs_service.dart';

part 'auth_interceptor.g.dart';

@Riverpod(keepAlive: true)
Interceptor authInterceptor(Ref ref) {
  final authStorageService = InjectionContainer.get<IAuthStorageService>();
  return AuthInterceptor(authStorageService);
}

final class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._authStorageService);

  final IAuthStorageService _authStorageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    final token = await _authStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
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
