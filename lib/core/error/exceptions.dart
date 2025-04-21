final class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

final class SystemException implements Exception {
  const SystemException(this.message);

  final String message;
}

final class NetworkException implements Exception {
  const NetworkException(this.message);

  final String message;
}
