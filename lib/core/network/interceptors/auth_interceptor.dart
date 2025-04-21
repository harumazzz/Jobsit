import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_interceptor.g.dart';

@riverpod
Interceptor authInterceptor(Ref ref) {
  return const AuthInterceptor();
}

class AuthInterceptor extends Interceptor {
  const AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    // TODO(self): add token
    // options.headers['Authorization'] = 'Bearer $token';
    super.onRequest(options, handler);
  }
}
