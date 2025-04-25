# Riverpod State Management

## Overview

Riverpod is a state management library for Flutter that improves upon Provider. Created by the same
author, Riverpod offers compile-time safety, testability, and a more intuitive API for managing
application state.

## Key Benefits

-   **Compile-time Safety**: Catches errors at compile time instead of runtime
-   **Provider Independence**: Providers can be declared anywhere, not just in widgets
-   **No Context Requirement**: Access state without BuildContext
-   **Testability**: Easily mock and override providers for testing
-   **Auto-disposal**: Automatically disposes resources when no longer needed
-   **Devtools Integration**: Works with Flutter DevTools for debugging
-   **Caching and Memoization**: Efficient computation with built-in caching

## Provider Types

### Provider

For simple, immutable values that never change.

```dart
final helloWorldProvider = Provider<String>((ref) {
  return 'Hello world';
});
```

### StateProvider

For simple state that can be mutated from outside.

```dart
final counterProvider = StateProvider<int>((ref) => 0);

// Usage
final counter = ref.watch(counterProvider);
ref.read(counterProvider.notifier).state++; // Increment
```

### StateNotifierProvider

For complex state with controlled mutations through methods.

```dart
class Counter extends StateNotifier<int> {
  Counter() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

final counterProvider = StateNotifierProvider<Counter, int>((ref) {
  return Counter();
});

// Usage
final count = ref.watch(counterProvider);
ref.read(counterProvider.notifier).increment();
```

### FutureProvider

For asynchronous data that returns a Future.

```dart
final userProvider = FutureProvider.autoDispose<User>((ref) async {
  return fetchUserFromApi();
});

// Usage
final userAsyncValue = ref.watch(userProvider);
return userAsyncValue.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### StreamProvider

For streaming data sources.

```dart
final postsProvider = StreamProvider<List<Post>>((ref) {
  return firestore.collection('posts').snapshots().map((snapshot) =>
    snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList()
  );
});
```

### NotifierProvider

A modern alternative to StateNotifierProvider (introduced in Riverpod 2.0).

```dart
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(() {
  return CounterNotifier();
});
```

### AsyncNotifierProvider

For complex async state with controlled mutations.

```dart
class UserNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() => fetchUser();

  Future<void> updateProfile(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await updateUserProfile(name);
      return user;
    });
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, User>(() {
  return UserNotifier();
});
```

## Provider Modifiers

### Family

Parameterizes a provider to create variations based on external values.

```dart
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  return fetchUser(userId);
});

// Usage with different parameters
final user1 = ref.watch(userProvider('user_1'));
final user2 = ref.watch(userProvider('user_2'));
```

### AutoDispose

Automatically destroys the state when no longer used.

```dart
final searchProvider = StateProvider.autoDispose<String>((ref) => '');

// Keep alive conditionally
final searchProvider = StateProvider.autoDispose<String>((ref) {
  ref.keepAlive();
  return '';
});
```

## Riverpod Generator

`riverpod_generator` is a code generation package that reduces boilerplate when working with
Riverpod.

### Key Features

-   **Annotation-based**: Use annotations to generate provider code
-   **Reduced Boilerplate**: Minimize repetitive provider declarations
-   **Type Safety**: Maintains Riverpod's type-safe approach
-   **Cleaner Code**: More readable and maintainable code

### Setup

1. **Add Dependencies**:

```yaml
dependencies:
    flutter_riverpod: ^2.3.6
    riverpod_annotation: ^2.1.1

dev_dependencies:
    build_runner: ^2.4.6
    riverpod_generator: ^2.2.3
```

2. **Create Annotated Providers**:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counter.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

// Simple provider
@riverpod
String helloWorld(HelloWorldRef ref) => 'Hello world';

// Future provider
@riverpod
Future<User> user(UserRef ref) async => fetchUser();

// Parameterized provider
@riverpod
Future<User> userById(UserByIdRef ref, String id) async => fetchUser(id);
```

3. **Run Code Generation**:

```bash
flutter pub run build_runner build
```

4. **Use Generated Providers**:

```dart
class CounterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return ElevatedButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      child: Text('Count: $count'),
    );
  }
}
```

## Integration with Flutter Hooks (hooks_riverpod)

```dart
class SearchScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchResults = ref.watch(searchResultsProvider(searchController.text));

    return Column(
      children: [
        TextField(controller: searchController),
        searchResults.when(
          data: (results) => ResultsList(results),
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }
}
```

## Best Practices

1. **Use Provider Organization**:

    - Group related providers in feature-based files
    - Use prefixes for clarity (e.g., `userProfileProvider`)

2. **Provider Dependencies**:
    - Inject dependencies through the ref parameter
    - Prefer composition over inheritance

```dart
@riverpod
Future<List<Post>> userPosts(UserPostsRef ref) async {
  // Depend on another provider
  final userId = ref.watch(currentUserIdProvider);
  return fetchPostsByUserId(userId);
}
```

3. **Error Handling**:

    - Use AsyncValue.guard for clean error handling
    - Always handle loading and error states

4. **Testing**:
    - Use ProviderContainer for unit testing
    - Override providers for testing specific scenarios

```dart
test('counter increments', () {
  final container = ProviderContainer();
  expect(container.read(counterProvider), 0);

  container.read(counterProvider.notifier).increment();
  expect(container.read(counterProvider), 1);
});
```

5. **State Persistence**:
    - Use SharedPreferences or Hive with Riverpod for persistence
    - Create persistence adapters for providers

## Migration from Provider

```dart
// Before with Provider
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}

final counterProvider = ChangeNotifierProvider((ref) => Counter());

// After with Riverpod
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

## Advanced Patterns

### Provider Observers

```dart
class Logger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('Provider ${provider.name} updated: $newValue');
  }
}

// Use in ProviderScope
ProviderScope(
  observers: [Logger()],
  child: MyApp(),
)
```

### Caching and Ref.keepAlive

```dart
@riverpod
class ExpensiveComputation extends _$ExpensiveComputation {
  @override
  Future<Result> build() async {
    // Keep this provider alive for 5 minutes
    final link = ref.keepAlive();
    Timer(Duration(minutes: 5), () => link.close());

    return compute();
  }
}
```

### Selective Rebuilds

```dart
// Only rebuild when specific property changes
final user = ref.watch(userProvider.select((user) => user.name));
```
