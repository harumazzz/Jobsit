/// {@template server_exception}
/// An exception that occurs when there is an issue with the server.
/// {@endtemplate}
final class ServerException implements Exception {
  /// {@macro server_exception}
  const ServerException(this.message);

  /// The error message describing the server issue.
  final String message;
}

/// {@template system_exception}
/// An exception that occurs when there is an issue with the system.
/// {@endtemplate}
final class SystemException implements Exception {
  /// {@macro system_exception}
  const SystemException(this.message);

  /// The error message describing the system issue.
  final String message;
}

/// {@template network_exception}
/// An exception that occurs when there is a network connectivity issue.
/// {@endtemplate}
final class NetworkException implements Exception {
  /// {@macro network_exception}
  const NetworkException(this.message);

  /// The error message describing the network issue.
  final String message;
}
