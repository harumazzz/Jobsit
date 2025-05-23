import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

/// Configures the dependencies for the application using GetIt.
///
/// This function is typically called by the `injectable` code generator.
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
void _configureDependencies(final GetIt getIt) => init(
  getIt,
  environment: Environment.current,
);

/// A simple service locator for managing dependencies using GetIt.
///
/// This class provides a centralized way to access registered dependencies
/// throughout the application.
class InjectionContainer {
  const InjectionContainer._();

  static final GetIt _getIt = GetIt.asNewInstance();

  /// Injects all the necessary dependencies into the GetIt container.
  ///
  /// This method should be called once at the application startup.
  static void injectDependencies() => _configureDependencies(_getIt);

  /// Resets the GetIt container, removing all registered dependencies.
  ///
  /// This is useful for testing or re-initializing the application state.
  static Future<void> reset() async => _getIt.reset();

  /// Retrieves an instance of the registered dependency of type [T].
  ///
  /// Throws an assertion error if the type [T] is not registered.
  static T get<T extends Object>() {
    assert(_getIt.isRegistered<T>(), '$T not registered');
    return _getIt.get<T>();
  }
}

/// Defines the different environments for the application.
///
/// This class provides constants for development and production environments
/// and a way to get the current environment based on the build mode.
abstract class Environment {
  /// Gets the current environment based on the build mode.
  ///
  /// Returns [Environment.prod] in release mode, otherwise [Environment.dev].
  // ignore: lines_longer_than_80_chars
  static String get current => kReleaseMode ? Environment.prod : Environment.dev;

  /// Constant representing the development environment.
  static const dev = 'dev';

  /// Constant representing the production environment.
  static const prod = 'prod';
}
