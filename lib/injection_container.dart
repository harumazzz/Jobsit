import 'package:get_it/get_it.dart';

class InjectionContainer {
  const InjectionContainer._();

  static final GetIt _getIt = GetIt.asNewInstance();

  static void register<T extends Object>(T Function() builder) {
    if (!_getIt.isRegistered<T>()) {
      _getIt.registerSingleton<T>(builder());
    }
  }

  static void injectDependencies() {}

  static Future<void> reset() async => _getIt.reset();

  static T get<T extends Object>() {
    assert(_getIt.isRegistered<T>(), 'Injection not registered');
    return _getIt.get<T>();
  }
}
