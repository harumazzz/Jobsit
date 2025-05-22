import 'package:dart_either/dart_either.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// An abstract class representing a use case in the application.
///
/// A use case executes a specific piece of business logic.
/// [Type] is the return type of the use case.
/// [Params] is the type of parameters required to execute the use case.
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns an [Either] containing a [Failure] on error, or [Type] on success.
  Future<Either<Failure, Type>> call(final Params params);
}

/// A class representing no parameters for a use case.
///
/// This can be used when a use case does not require any input parameters.
/// It extends [Equatable] for value comparison.
final class NoParams extends Equatable {
  /// Creates an instance of [NoParams].
  const NoParams();

  @override
  List<Object?> get props => [];
}

/// A constant instance of [NoParams].
///
/// Useful for use cases that do not require parameters, allowing for a
/// concise way to call them (e.g., `useCase(nil)`).
const nil = NoParams();
