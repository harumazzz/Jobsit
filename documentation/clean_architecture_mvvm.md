# Clean Architecture with MVVM

## Clean Architecture Overview

Clean Architecture is a software design philosophy that separates the elements of a design into ring
levels. The main rule of clean architecture is that code dependencies can only come from outer
levels inward.

### Layers

1. **Domain Layer** - Contains business logic and rules, entities, and use cases.
2. **Data Layer** - Implementation of repositories defined in the domain layer, handles data
   sources.
3. **Presentation Layer** - UI components and presentation logic (ViewModels).
4. **Application Layer** - Cross-cutting concerns like dependency injection and navigation.

## MVVM Pattern

Model-View-ViewModel (MVVM) is an architectural pattern used in the presentation layer that helps
separate the business and presentation logic from the UI.

### Components

-   **Model**: The data and business logic of the application
-   **View**: The UI components (Flutter widgets)
-   **ViewModel**: Connects the Model and View, provides data to the view and handles user
    interactions

## Implementation in Flutter

In our Flutter application, we implement Clean Architecture with MVVM as follows:

### Project Structure

```
lib/
├── application/    # Application services, DI setup
├── core/           # Core utilities and constants
├── data/           # Data sources, repositories implementations, models
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/         # Entities, repositories interfaces, use cases
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/   # UI components and ViewModels
    ├── pages/
    ├── viewmodels/
    └── widgets/
```

### Data Flow

1. UI events are captured by the View
2. The View notifies the ViewModel
3. The ViewModel executes Use Cases from the Domain layer
4. Use Cases interact with Repository interfaces
5. Repository implementations in the Data layer fetch data and return it through the layers
6. The ViewModel processes the data and exposes it to the View
7. The View renders based on the state from the ViewModel

## Benefits

-   **Testability**: Each layer can be tested independently
-   **Maintainability**: Clear separation of concerns makes the codebase easier to maintain
-   **Scalability**: New features can be added without changing existing code
-   **Flexibility**: Implementation details can be changed without affecting other parts
