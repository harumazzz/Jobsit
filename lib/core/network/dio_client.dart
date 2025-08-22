import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_constant.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

part 'dio_client.g.dart';

/// Provides a [Dio] instance configured for the main application API.
///
/// This Dio instance uses [ApiConstant.baseUrl] and includes
/// [LoggingInterceptor] and [AuthInterceptor].
/// It is kept alive throughout the application's lifecycle.
@Riverpod(keepAlive: true)
Dio dio(final Ref ref) {
  final option = BaseOptions(
    baseUrl: ApiConstant.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );
  final dio = Dio(option);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggingInterceptor = ref.watch(loggingInterceptorProvider);
  dio.interceptors.addAll([loggingInterceptor, authInterceptor]);
  return dio;
}

/// Provides a [Dio] instance configured for the province API.
///
/// This Dio instance uses [ApiConstant.provinceApi] and includes
/// [LoggingInterceptor], [AuthInterceptor].
@riverpod
Dio provinceDio(final Ref ref) {
  final option = BaseOptions(
    baseUrl: ApiConstant.provinceApi,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );
  final dio = Dio(option);
  final authInterceptor = ref.watch(authInterceptorProvider);
  final loggingInterceptor = ref.watch(loggingInterceptorProvider);
  final cacheInterceptor = ref.watch(cacheInterceptorProvider);
  dio.interceptors.addAll([
    loggingInterceptor,
    authInterceptor,
    cacheInterceptor,
  ]);
  return dio;
}
