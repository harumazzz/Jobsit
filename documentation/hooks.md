# Flutter Hooks

## Overview

Flutter Hooks is inspired by React Hooks and provides a new way to manage the state and lifecycle of
Flutter widgets. Hooks are functions that allow you to "hook into" Flutter widget lifecycle and
state without using StatefulWidget.

## Key Benefits

-   **Code Reusability**: Extract stateful logic and reuse it across components
-   **Reduced Boilerplate**: Avoid the verbosity of StatefulWidget
-   **Composition**: Combine multiple hooks to create complex state management
-   **Testability**: Easier to test since hooks are just functions
-   **Readability**: More declarative and focused code

## Common Hooks

### useState

Manages a single value that will rebuild the widget when changed.

```dart
final counter = useState(0);
// Access the value
print(counter.value);
// Update the value
counter.value++;
```

### useEffect

Performs side effects and cleanup in response to changes in dependencies.

```dart
useEffect(() {
  // Setup code (runs on first build and when dependencies change)
  final subscription = stream.listen((_) {});

  // Cleanup function (runs before next effect or when widget disposes)
  return () => subscription.cancel();
}, [stream]); // Dependencies array
```

### useContext

Accesses a value from the BuildContext.

```dart
final theme = useContext().theme;
```

### useTextEditingController

Creates and disposes a TextEditingController.

```dart
final controller = useTextEditingController(text: 'Initial text');
```

### useFuture

Handles a Future and provides its current state.

```dart
final snapshot = useFuture(fetchDataFuture);
if (snapshot.connectionState == ConnectionState.waiting) {
  return CircularProgressIndicator();
}
return Text(snapshot.data ?? 'No data');
```

### useStream

Similar to useFuture but for Streams.

```dart
final snapshot = useStream(dataStream);
```

## Creating Custom Hooks

Custom hooks allow you to extract and reuse stateful logic.

```dart
// Custom hook for debouncing text input
Hook<String> useDebounceText(String text, {Duration delay = const Duration(milliseconds: 500)}) {
  final debounced = useState(text);

  useEffect(() {
    final timer = Timer(delay, () {
      debounced.value = text;
    });

    return timer.cancel;
  }, [text]);

  return debounced;
}

// Usage
final searchQuery = useState('');
final debouncedQuery = useDebounceText(searchQuery.value);

TextField(
  onChanged: (value) => searchQuery.value = value,
),
// Use debouncedQuery.value for API calls
```

## Integration with Riverpod (hooks_riverpod)

The `hooks_riverpod` package combines Flutter Hooks with Riverpod for state management.

```dart
// Accessing a provider with hooks
final Counter counterProvider = Provider((ref) => Counter());

// In a HookConsumerWidget
class CounterScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    final name = useState('');

    return Column(
      children: [
        Text('Count: ${counter.count}'),
        TextField(
          value: name.value,
          onChanged: (value) => name.value = value,
        ),
      ],
    );
  }
}
```

## Best Practices

1. **Keep Hooks at the Top Level**: Don't call hooks inside conditions, loops, or nested functions
2. **Don't Change the Order of Hook Calls**: Hooks rely on a stable calling order
3. **Name Custom Hooks with 'use' Prefix**: This is a convention to identify hooks
4. **Keep Dependencies Array Accurate**: For useEffect, include all variables used inside the effect
5. **Prefer Small, Focused Hooks**: Create custom hooks for reusable logic
6. **Don't Overuse**: Some complex stateful logic still works better with StatefulWidget

## Setup Process

1. **Add Dependency**:

```yaml
dependencies:
    flutter_hooks: ^0.21.2
    # For Riverpod integration
    hooks_riverpod: ^2.6.1
```

2. **Use HookWidget Instead of StatelessWidget**:

```dart
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final counter = useState(0);

    return ElevatedButton(
      onPressed: () => counter.value++,
      child: Text('Count: ${counter.value}'),
    );
  }
}
```

3. **Or Use HookConsumerWidget with Riverpod**:

```dart
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = useState(0);
    final theme = ref.watch(themeProvider);

    return ElevatedButton(
      onPressed: () => counter.value++,
      child: Text('Count: ${counter.value}'),
    );
  }
}
```
