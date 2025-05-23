import 'package:equatable/equatable.dart';

/// Base abstract class for all failures in the application.
///
/// Acts as a base for specific failure types and ensures that all failures
/// contain a message that can be displayed to the user or logged.
abstract class Failure extends Equatable {
  /// Creates a new [Failure] instance with the provided error message.
  ///
  /// @param message The error message describing the failure.
  const Failure(this.message);

  /// A descriptive message explaining the failure.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Represents a failure that occurred while communicating with a server.
///
/// Used when API calls fail, timeout, or return unexpected responses.
final class ServerFailure extends Failure {
  /// Creates a new [ServerFailure] instance with the provided error message.
  ///
  /// @param message The error message describing the server failure.
  const ServerFailure(super.message);
}

/// Represents a failure that occurred while working with cached data.
///
/// Used when there are issues reading from or writing to the local cache.
final class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] instance with the provided error message.
  ///
  /// @param message The error message describing the cache failure.
  const CacheFailure(super.message);
}

/// Represents a failure due to an invalid email format.
///
/// Used during user input validation when email format is incorrect.
final class InvalidEmailFailure extends Failure {
  /// Creates a new [InvalidEmailFailure] instance with the provided
  /// error message.
  ///
  /// @param message The error message describing the email validation
  /// failure.
  const InvalidEmailFailure(super.message);
}

/// Represents a failure that occurred while accessing storage.
///
/// Used when there are issues with file system or persistent storage
/// operations.
final class StorageFailure extends Failure {
  /// Creates a new [StorageFailure] instance with the provided error
  /// message.
  ///
  /// @param message The error message describing the storage failure.
  const StorageFailure(super.message);
}

/// Represents a failure due to a password being too short.
///
/// Used during user input validation when password doesn't meet minimum
/// length requirements.
final class ShortPasswordFailure extends Failure {
  /// Creates a new [ShortPasswordFailure] instance with the provided
  /// error message.
  ///
  /// @param message The error message describing the password validation
  /// failure.
  const ShortPasswordFailure(super.message);
}

/// Represents a successful operation with no return value.
///
/// Used when an operation completes successfully but doesn't need to
/// return any data.
final class Success extends Equatable {
  /// Creates a new [Success] instance.
  const Success();

  @override
  List<Object?> get props => [];
}
