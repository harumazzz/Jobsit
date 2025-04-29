import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart' as log_package;

abstract class AppLogger {
  void info(String message);
  void debug(dynamic message);
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]);
}

@Injectable(as: AppLogger)
@prod
final class ProductionLogger implements AppLogger {
  ProductionLogger()
    : _logger = log_package.Logger(printer: log_package.PrettyPrinter(colors: false, printEmojis: false));

  final log_package.Logger _logger;

  @override
  void info(String message) async {
    _logger.i(message);
  }

  @override
  void debug(dynamic message) async {}

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) async {
    _logger.w(message, error: error);
  }
}

@Injectable(as: AppLogger)
@dev
final class DevelopmentLogger implements AppLogger {
  DevelopmentLogger() : _logger = log_package.Logger(printer: log_package.PrettyPrinter());

  final log_package.Logger _logger;

  @override
  void info(String message) async {
    _logger.i(message);
  }

  @override
  void debug(dynamic message) async {
    _logger.d(message);
  }

  @override
  void error(dynamic message, [dynamic error, StackTrace? stackTrace]) async {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
