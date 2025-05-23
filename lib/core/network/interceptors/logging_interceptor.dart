import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../injection_container.dart';
import '../../logger/app_logger.dart';

part 'logging_interceptor.g.dart';

/// Provides a [LoggingInterceptor] instance.
///
/// This interceptor is responsible for logging details of outgoing requests,
/// incoming responses, and any errors that occur during network communication.
/// It is kept alive throughout the application's lifecycle.
@Riverpod(keepAlive: true)
Interceptor loggingInterceptor(final Ref ref) {
  final logger = InjectionContainer.get<AppLogger>();
  return LoggingInterceptor(logger);
}

/// A Dio [Interceptor] that logs network request, response, and error details.
///
/// Uses an [AppLogger] instance to output log messages.
@injectable
class LoggingInterceptor extends Interceptor {
  /// Creates a [LoggingInterceptor].
  ///
  /// Requires an [AppLogger] for logging.
  const LoggingInterceptor(this._logger);

  final AppLogger _logger;

  /// Called when a request is about to be sent.
  ///
  /// Logs the request method, path, headers, query parameters, and body.
  @override
  Future<void> onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    _logger
      ..info('➡️ REQUEST[${options.method}] => PATH: ${options.path}')
      ..debug('Headers: ${options.headers}')
      ..debug('Query: ${options.queryParameters}')
      ..debug('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  /// Called when a response is received.
  ///
  /// Logs the response status code, path, and data.
  @override
  Future<void> onResponse(
    final Response response,
    final ResponseInterceptorHandler handler,
  ) async {
    final path = response.requestOptions.path;
    _logger
      ..info('✅ RESPONSE[${response.statusCode}] => PATH: $path')
      ..debug('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  /// Called when an error occurs during a request.
  ///
  /// Logs the error status code (if available), path, message, and data.
  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;
    _logger
      ..error('⛔ ERROR[${err.response?.statusCode}] => PATH: $path')
      ..error('Message: ${err.message}')
      ..error('Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}
