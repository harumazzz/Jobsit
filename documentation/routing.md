# Routing with go_router

## go_router

`go_router` is a declarative routing package for Flutter that provides a simple API for defining
routes and navigating between them. It supports deep linking, nested navigation, and redirection.

### Key Features

-   **Declarative Routes**: Define all routes in one place
-   **Path Parameters**: Extract parameters from URL paths
-   **Query Parameters**: Handle query parameters in URLs
-   **Nested Navigation**: Support for nested navigation and multiple navigators
-   **Deep Linking**: Handle deep links and web URLs
-   **Navigation Guards**: Redirect users based on authentication or other conditions
-   **Error Handling**: Custom error pages for unknown routes

## go_router_builder

`go_router_builder` is a code generation package that works with `go_router` to generate type-safe
route helpers, reducing the risk of runtime errors from incorrect route names or parameter types.

### Benefits

-   **Type Safety**: Compile-time checking for route names and parameters
-   **Auto-completion**: IDE suggestions for routes and parameters
-   **Refactoring Support**: Rename routes and parameters with IDE tools

## Implementation in Our Project

### Basic Configuration

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return ProfileScreen(userId: userId);
      },
    ),
  ],
);
```

### Using Type-Safe Routes with go_router_builder

1. **Create a Routes File**:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:go_router_builder/go_router_builder.dart';

part 'routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<ProfileRoute>(path: '/profile/:userId')
class ProfileRoute extends GoRouteData {
  const ProfileRoute({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ProfileScreen(userId: userId);
}
```

2. **Generate Router Configuration**:

```dart
final router = GoRouter(
  routes: $appRoutes,
);
```

3. **Type-Safe Navigation**:

```dart
// Navigate to home
HomeRoute().go(context);

// Navigate to profile
ProfileRoute(userId: '123').go(context);

// Navigate and replace current route
LoginRoute().replace(context);
```

## Handling Authentication

```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = authBloc.state.isAuthenticated;
    final bool isLoginRoute = state.matchedLocation == '/login';

    // If not logged in and not on login page, redirect to login
    if (!isLoggedIn && !isLoginRoute) return '/login';

    // If logged in and on login page, redirect to home
    if (isLoggedIn && isLoginRoute) return '/';

    // No redirection needed
    return null;
  },
  routes: [
    // Route definitions...
  ],
);
```

## Shell Routes for Bottom Navigation

```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExploreScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
```

## Error Handling

```dart
final router = GoRouter(
  errorBuilder: (context, state) => NotFoundScreen(
    error: state.error,
  ),
  routes: [
    // Route definitions...
  ],
);
```
