import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

@InjectableInit(initializerName: 'init', preferRelativeImports: true, asExtension: false)
void _configureDependencies(GetIt getIt) => init(getIt, environment: Environment.current);

class InjectionContainer {
  const InjectionContainer._();

  static final GetIt _getIt = GetIt.instance;

  static void injectDependencies() => _configureDependencies(_getIt);

  static Future<void> reset() async => _getIt.reset();

  static T get<T extends Object>() {
    assert(_getIt.isRegistered<T>(), 'Injection not registered');
    return _getIt.get<T>();
  }
}

abstract class Environment {
  static String get current => kReleaseMode ? Environment.prod : Environment.dev;

  static const dev = 'dev';
  static const prod = 'prod';
}
