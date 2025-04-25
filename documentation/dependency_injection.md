# Dependency Injection with Injectable and GetIt

## Overview

Dependency Injection (DI) is a design pattern that helps to implement Inversion of Control (IoC),
where dependencies are provided to a class rather than the class creating them internally. This
approach promotes loose coupling, testability, and maintainability.

In our project, we use three key libraries for dependency injection:

-   **GetIt**: A service locator for dependency injection
-   **Injectable**: A code generation library that works with GetIt
-   **Injectable Generator**: Generates the boilerplate code for dependency registration

## GetIt

GetIt is a simple service locator for Dart and Flutter projects. It allows you to register
dependencies and retrieve them from anywhere in your app.

### Key Features

-   **Synchronous and Asynchronous Registration**: Register dependencies that are created
    immediately or lazily
-   **Singleton Management**: Register dependencies as singletons, lazy singletons, or factory
    functions
-   **Scoped Instances**: Create and dispose instances within specific scopes
-   **Environment-Based Registration**: Register different implementations based on environment
    (e.g., production, testing)

## Injectable

Injectable is a code generation package that simplifies the process of registering dependencies with
GetIt by using annotations.

### Key Annotations

-   **@injectable**: Marks a class as injectable
-   **@singleton**: Registers a class as a singleton
-   **@lazySingleton**: Registers a class as a lazy singleton (instantiated on first use)
-   **@factoryMethod**: Uses a static method to create an instance
-   **@Environment**: Specifies the environment for registration
-   **@Named**: Provides a name for the registration
-   **@preResolve**: Resolves async dependencies during initialization

## Implementation in Our Project

### Setup Process

1. **Create a Service Locator File**:

```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'service_locator.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: false, // default
)
void configureDependencies() => init(getIt);
```

2. **Initialize in main.dart**:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(MyApp());
}
```

### Registering Dependencies

#### Basic Injectable

```dart
import 'package:injectable/injectable.dart';

@injectable
class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  Future<User> getUser(String id) async {
    // Implementation
  }
}
```

#### Singleton

```dart
import 'package:injectable/injectable.dart';

@singleton
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<bool> login(String username, String password) async {
    // Implementation
  }
}
```

#### Lazy Singleton

```dart
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  void logEvent(String name, Map<String, dynamic> parameters) {
    // Implementation
  }
}
```

#### Named Instances

```dart
import 'package:injectable/injectable.dart';

abstract class CacheStorage {
  Future<void> save(String key, String value);
  Future<String?> get(String key);
}

@Named("secure")
@injectable
class SecureStorage implements CacheStorage {
  @override
  Future<String?> get(String key) async {
    // Implementation
  }

  @override
  Future<void> save(String key, String value) async {
    // Implementation
  }
}

@Named("shared_prefs")
@injectable
class SharedPrefsStorage implements CacheStorage {
  @override
  Future<String?> get(String key) async {
    // Implementation
  }

  @override
  Future<void> save(String key, String value) async {
    // Implementation
  }
}

// Injecting named instance
@injectable
class ProfileRepository {
  final CacheStorage _storage;

  ProfileRepository(@Named("secure") this._storage);

  // Implementation
}
```

#### Environment-specific Dependencies

```dart
import 'package:injectable/injectable.dart';

@Environment('dev')
@injectable
class MockApiClient implements ApiClient {
  // Mock implementation
}

@Environment('prod')
@injectable
class RealApiClient implements ApiClient {
  // Real implementation
}

// Initialize with environment
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies(String environment) =>
    init(getIt, environment: environment);

// In main.dart
void main() {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );
  configureDependencies(environment);
}
```

#### Factory Registrations

```dart
import 'package:injectable/injectable.dart';

@injectable
class UserService {
  // Implementation
}
```

#### Registering Third-Party or External Dependencies

```dart
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';

@module
abstract class ExternalDependenciesModule {
  @singleton
  Dio get dio => Dio()
    ..options = BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 5),
    )
    ..interceptors.add(LogInterceptor());

  @preResolve  // for async initialization
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
```

### Using Registered Dependencies

#### Direct Usage with GetIt

```dart
final userRepository = getIt<UserRepository>();
final result = await userRepository.getUser('123');

// With named instances
final secureStorage = getIt<CacheStorage>(instanceName: 'secure');
```

#### With Factory Registration

```dart
// Each call creates a new instance
final service1 = getIt<UserService>();
final service2 = getIt<UserService>();
// service1 != service2
```

#### Async Initialization

```dart
@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => await init(getIt);

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(MyApp());
}
```

## Best Practices

1. **Keep Services and Repositories Injectable**: Apply DI to these layers
2. **Avoid GetIt in Domain Layer**: Keep your domain layer pure and pass dependencies explicitly
3. **Use Interface Abstractions**: Register implementations against interfaces for better
   testability
4. **Organize Modules Logically**: Group related dependencies in modules
5. **Consider Using Factory for Ephemeral Objects**: Use factory registration for objects that
   should not be shared
6. **Reset in Tests**: Use `getIt.reset()` in test tearDown to prevent test cross-contamination
7. **Use Proper Scoping**: Consider lifecycle scoping for features that need it

## Generating Code

Run the build_runner command to generate the dependency injection code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For continuous code generation during development:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```
