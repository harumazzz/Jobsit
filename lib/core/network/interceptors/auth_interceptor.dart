import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../injection_container.dart';
import '../../services/shared_prefs_service.dart';

part 'auth_interceptor.g.dart';

/// Provides an [AuthInterceptor] instance.
///
/// This interceptor is responsible for adding authentication tokens to
/// outgoing requests and handling error responses by extracting more
/// specific messages if available. It is kept alive throughout the
/// application's lifecycle.
@Riverpod(keepAlive: true)
Interceptor authInterceptor(final Ref ref) {
  final authStorageService = InjectionContainer.get<IAuthStorageService>();
  return AuthInterceptor(authStorageService);
}

/// A Dio [Interceptor] that handles authentication for API requests.
///
/// It adds the authorization token to request headers and processes
/// error responses to extract meaningful messages.
final class AuthInterceptor extends Interceptor {
  /// Creates an [AuthInterceptor].
  ///
  /// Requires an [IAuthStorageService] to retrieve the authentication token.
  const AuthInterceptor(this._authStorageService);

  final IAuthStorageService _authStorageService;

  /// Called when a request is about to be sent.
  ///
  /// Adds 'Content-Type' and 'Accept' headers. If an authentication token
  /// is available from [_authStorageService], it adds an 'Authorization'
  /// header with the Bearer token.
  @override
  Future<void> onRequest(
    final RequestOptions options,
    final RequestInterceptorHandler handler,
  ) async {
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    final token = await _authStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  /// Called when an error occurs during a request.
  ///
  /// Attempts to extract a more specific error message from the response data
  /// if the response contains a 'message' field. Otherwise, uses the default
  /// Dio error message.
  @override
  Future<void> onError(
    final DioException err,
    final ErrorInterceptorHandler handler,
  ) async {
    var message = err.message;
    if (err.response != null && err.response?.data != null) {
      if (err.response!.data is Map<String, dynamic>) {
        final responseData = err.response!.data as Map<String, dynamic>;
        final hasMessage = responseData.containsKey('message');
        if (hasMessage && responseData['message'] is String) {
          final serverMessage = responseData['message'] as String;
          if (serverMessage.isNotEmpty) {
            message = serverMessage;
          }
        }
      }
    }
    handler.next(err.copyWith(message: message));
  }
}
