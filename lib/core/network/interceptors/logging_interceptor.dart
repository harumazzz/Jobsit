import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../injection_container.dart';
import '../../logger/app_logger.dart';

part 'logging_interceptor.g.dart';

@Riverpod(keepAlive: true)
Interceptor loggingInterceptor(Ref ref) {
  return InjectionContainer.get<LoggingInterceptor>();
}

@injectable
class LoggingInterceptor extends Interceptor {
  const LoggingInterceptor(this._logger);

  final AppLogger _logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _logger.info('➡️ REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.debug('Headers: ${options.headers}');
    _logger.debug('Query: ${options.queryParameters}');
    _logger.debug('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _logger.info('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger.debug('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _logger.error('⛔ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger.error('Message: ${err.message}');
    _logger.error('Data: ${err.response?.data}');
    super.onError(err, handler);
  }
}
