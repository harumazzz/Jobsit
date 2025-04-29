import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'api_constant.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

part 'dio_client.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
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

@riverpod
Dio provinceDio(Ref ref) {
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
  dio.interceptors.addAll([loggingInterceptor, authInterceptor, cacheInterceptor]);
  return dio;
}
