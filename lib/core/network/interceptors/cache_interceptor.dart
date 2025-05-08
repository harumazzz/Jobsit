import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_interceptor.g.dart';

@riverpod
DioCacheInterceptor cacheInterceptor(Ref ref) {
  final cacheOption = CacheOptions(
    store: MemCacheStore(),
    hitCacheOnErrorCodes: const [500],
    hitCacheOnNetworkFailure: true,
    maxStale: const Duration(days: 7),
  );
  return DioCacheInterceptor(options: cacheOption);
}
