# Freezed and JSON Serialization

## Freezed

Freezed is a code generation package that helps create immutable classes in Dart. It minimizes
boilerplate for data classes and offers additional functionality like union types (sealed classes).

### Key Features

-   **Immutable Classes**: Generate immutable data classes with minimal code
-   **Union Types/Sealed Classes**: Create type-safe union types for representing different states
-   **Copy With**: Easy deep copying with partial updates
-   **Equality**: Automatic implementation of equality (`==`) and `hashCode`
-   **Pattern Matching**: Exhaustive pattern matching for union types

## freezed_annotation

The `freezed_annotation` package provides annotations that work with the code generator:

-   `@freezed`: Applied to classes to make them freezed classes
-   `@Default()`: Set default values for fields
-   `@Assert()`: Add assertions to validate the class state
-   `@late`: Initialize fields lazily
-   `@Freezed(makeCollectionsUnmodifiable: false)`: Configure freezed behavior

## json_annotation

The `json_annotation` package provides annotations for JSON serialization/deserialization with
`json_serializable`:

-   `@JsonSerializable()`: Marks a class for JSON serialization
-   `@JsonKey()`: Customizes serialization of specific fields
-   `@JsonValue`: Specifies the serialized value for enum values

## Usage in Our Project

### Basic Data Class

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    @Default('') String email,
    @JsonKey(name: 'profile_picture') String? profilePicture,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Union Types (Sealed Classes)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated(User user) = Authenticated;
  const factory AuthState.error(String message) = AuthError;
}
```

### Pattern Matching

```dart
Widget build(BuildContext context) {
  return authState.when(
    initial: () => WelcomeScreen(),
    loading: () => LoadingIndicator(),
    authenticated: (user) => HomeScreen(user: user),
    error: (message) => ErrorScreen(message: message),
  );
}
```

## Setup Process

1. **Add Dependencies**:

```yaml
dependencies:
    freezed_annotation: ^3.0.0
    json_annotation: ^4.9.0

dev_dependencies:
    build_runner: ^2.4.15
    freezed: ^3.0.6
    json_serializable: ^6.9.5
```

2. **Generate Code**:

```bash
flutter pub run build_runner build
# or for continuous generation during development
flutter pub run build_runner watch
```

3. **Remember to Add Part Declarations**:

```dart
part 'your_file.freezed.dart';
part 'your_file.g.dart';
```
