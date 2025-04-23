import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'logging_interceptor.g.dart';

@Riverpod(keepAlive: true)
Interceptor loggingInterceptor(Ref ref) {
  var logger = null as Logger?;
  if (kDebugMode) {
    logger = Logger();
  }
  return LoggingInterceptor(logger);
}

class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor(this._logger);

  final Logger? _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _logger?.i('➡️ REQUEST[${options.method}] => PATH: ${options.path}');
    _logger?.d('Headers: ${options.headers}');
    _logger?.d('Query: ${options.queryParameters}');
    _logger?.d('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _logger?.i('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger?.d('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logger?.e('⛔ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger?.e('Message: ${err.message}');
    _logger?.e('Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}
