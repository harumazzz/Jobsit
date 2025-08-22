import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart' as log_package;

/// {@template app_logger}
/// An abstract interface for logging application events.
///
/// This class defines a standard set of logging methods that can be
/// implemented by different logger concrete classes (e.g., for development
/// or production environments).
/// {@endtemplate}
abstract class AppLogger {
  /// Logs an informational message.
  ///
  /// Typically used for logging events that are part of the normal operation
  /// of the application.
  void info(final String message);

  /// Logs a debug message.
  ///
  /// Used for detailed information useful during development and debugging.
  /// These messages might be suppressed in production environments.
  void debug(final dynamic message);

  /// Logs an error message.
  ///
  /// Optionally includes an [error] object and a [stackTrace].
  /// Used for reporting unexpected errors or exceptions that occur
  /// during application execution.
  void error(
    final dynamic message, [
    final dynamic error,
    final StackTrace? stackTrace,
  ]);
}

/// {@template production_logger}
/// A logger implementation for production environments.
///
/// This logger typically has debug messages disabled and may format
/// logs in a way suitable for production log aggregation systems.
/// It uses `logger.w` (warning) for errors to align with common
/// production logging practices where 'error' might imply a more severe,
/// system-halting issue.
/// {@endtemplate}
@Injectable(as: AppLogger)
@prod
final class ProductionLogger implements AppLogger {
  /// {@macro production_logger}
  ///
  /// Initializes the logger with a `PrettyPrinter` configured for
  /// production (no colors, no emojis).
  ProductionLogger()
    : _logger = log_package.Logger(
        printer: log_package.PrettyPrinter(
          colors: false,
          printEmojis: false,
        ),
      );

  final log_package.Logger _logger;

  /// Logs an informational message using the underlying logger's `i` method.
  @override
  Future<void> info(final String message) async {
    _logger.i(message);
  }

  /// Debug logging is a no-op in the production logger.
  ///
  /// This method is implemented to fulfill the [AppLogger] interface
  /// but does not perform any action to avoid verbose logging in production.
  @override
  Future<void> debug(final dynamic message) async {
    // No-op for production
  }

  /// Logs a warning message (as an error) using the underlying logger's `w`.
  ///
  /// In this production logger, errors are logged as warnings.
  /// Optionally includes an [error] object. The [stackTrace] is not explicitly
  /// passed to `_logger.w` here as the `logger` package's `w` method
  /// doesn't have a direct `stackTrace` parameter like `e` does.
  /// The `error` object itself might contain stack trace information.
  @override
  Future<void> error(
    final dynamic message, [
    final dynamic error,
    final StackTrace? stackTrace,
  ]) async {
    _logger.w(message, error: error);
  }
}

/// {@template development_logger}
/// A logger implementation for development environments.
///
/// This logger enables detailed debug messages and typically formats
/// logs in a human-readable way, often with colors and emojis,
/// to aid in the development process.
/// {@endtemplate}
@Injectable(as: AppLogger)
@dev
final class DevelopmentLogger implements AppLogger {
  /// {@macro development_logger}
  ///
  /// Initializes the logger with a `PrettyPrinter` configured for
  /// development (colors and emojis enabled by default).
  DevelopmentLogger()
    : _logger = log_package.Logger(
        printer: log_package.PrettyPrinter(),
      );

  final log_package.Logger _logger;

  /// Logs an informational message using the underlying logger's `i` method.
  @override
  Future<void> info(final String message) async {
    _logger.i(message);
  }

  /// Logs a debug message using the underlying logger's `d` method.
  @override
  Future<void> debug(final dynamic message) async {
    _logger.d(message);
  }

  /// Logs an error message using the underlying logger's `e` method.
  ///
  /// Optionally includes an [error] object and its [stackTrace].
  @override
  Future<void> error(
    final dynamic message, [
    final dynamic error,
    final StackTrace? stackTrace,
  ]) async {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
