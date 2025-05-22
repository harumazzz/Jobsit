import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cache_interceptor.g.dart';

/// Provides a [DioCacheInterceptor] instance.
///
/// This interceptor is configured to cache responses in memory
/// ([MemCacheStore]). It will serve cached data on 500 errors and
/// network failures. Cached data is considered fresh for up to 7 days.
@riverpod
DioCacheInterceptor cacheInterceptor(final Ref ref) {
  final cacheOption = CacheOptions(
    store: MemCacheStore(),
    hitCacheOnErrorCodes: const [500],
    hitCacheOnNetworkFailure: true,
    maxStale: const Duration(days: 7),
  );
  return DioCacheInterceptor(options: cacheOption);
}
