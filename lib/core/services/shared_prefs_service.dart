import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../i18n/strings.g.dart';

/// Interface for a secure storage service.
///
/// Provides methods to read, write, and delete data securely.
abstract class ISecureStorageService {
  /// Reads a value from secure storage associated with the given [key].
  ///
  /// Returns the value if found, otherwise null.
  Future<String?> read(final String key);

  /// Writes a [value] to secure storage associated with the given [key].
  Future<void> write(final String key, final String value);

  /// Deletes a value from secure storage associated with the given [key].
  Future<void> delete(final String key);

  /// Deletes all data from secure storage.
  Future<void> deleteAll();
}

/// Implementation of [ISecureStorageService] using [FlutterSecureStorage].
///
/// This class is a singleton.
@Singleton(as: ISecureStorageService)
class SecureStorageService implements ISecureStorageService {
  /// Creates a [SecureStorageService].
  ///
  /// Requires a [FlutterSecureStorage] instance.
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(final String key) async {
    final String? value = await _storage.read(key: key);
    return value;
  }

  @override
  Future<void> write(final String key, final String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(final String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

/// Interface for an authentication token and user ID storage service.
///
/// Provides methods to manage authentication tokens and user IDs,
/// including saving, retrieving, deleting, and checking token expiration.
abstract class IAuthStorageService {
  /// Retrieves the authentication token.
  ///
  /// Returns the token if it exists and is not expired, otherwise null.
  /// Deletes the token if it's found to be expired.
  Future<String?> getToken();

  /// Saves the authentication [token] and records its timestamp.
  Future<void> saveToken(final String token);

  /// Deletes the authentication token and its timestamp.
  Future<void> deleteToken();

  /// Saves the [userId].
  Future<void> saveUserId(final int userId);

  /// Retrieves the user ID.
  ///
  /// Returns the user ID if saved, otherwise null.
  Future<int?> getUserId();

  /// Checks if the stored authentication token has expired.
  ///
  /// Returns true if the token is expired or not found, false otherwise.
  Future<bool> isTokenExpired();
}

/// Implementation of [IAuthStorageService].
///
/// Uses an [ISecureStorageService] to store authentication data.
/// This class is a singleton.
@Singleton(as: IAuthStorageService)
class AuthStorageService implements IAuthStorageService {
  /// Creates an [AuthStorageService].
  ///
  /// Requires an [ISecureStorageService] instance.
  AuthStorageService(this._secureStorageService);

  /// Key for storing the authentication token.
  static const String tokenKey = 'token';

  /// Key for storing the user ID.
  static const String userIdKey = 'userId';

  /// Key for storing the timestamp of when the token was saved.
  static const String tokenTimestampKey = 'tokenTimestamp';

  /// Duration in milliseconds for token expiration (5 hours).
  static const int tokenExpirationDuration = 5 * 60 * 60 * 1000;

  final ISecureStorageService _secureStorageService;

  @override
  Future<String?> getToken() async {
    final isExpired = await isTokenExpired();
    if (isExpired) {
      await deleteToken();
      return null;
    }
    final result = await _secureStorageService.read(tokenKey);
    return result;
  }

  @override
  Future<void> saveToken(final String token) async {
    await _secureStorageService.write(tokenKey, token);
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    await _secureStorageService.write(tokenTimestampKey, currentTimestamp);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorageService.delete(tokenKey);
    await _secureStorageService.delete(tokenTimestampKey);
  }

  @override
  Future<bool> isTokenExpired() async {
    final timestampString = await _secureStorageService.read(tokenTimestampKey);
    if (timestampString == null) {
      return true;
    }
    final timestamp = int.tryParse(timestampString) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    return (currentTime - timestamp) > tokenExpirationDuration;
  }

  @override
  Future<void> saveUserId(final int userId) async {
    await _secureStorageService.write(
      AuthStorageService.userIdKey,
      userId.toString(),
    );
  }

  @override
  Future<int?> getUserId() async {
    final result = await _secureStorageService.read(
      AuthStorageService.userIdKey,
    );
    return result != null ? int.tryParse(result) : null;
  }
}

/// Injectable module for providing storage-related dependencies.
@module
abstract class StorageModule {
  /// Provides a singleton instance of [FlutterSecureStorage].
  ///
  /// Configures Android and iOS specific options for secure storage.
  @singleton
  FlutterSecureStorage get secureStorage {
    const androidOption = AndroidOptions(encryptedSharedPreferences: true);
    const iosOption = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    );
    return const FlutterSecureStorage(
      aOptions: androidOption,
      iOptions: iosOption,
    );
  }
}

/// Service for managing application locale preferences.
///
/// This service provides methods to save and retrieve the user's preferred
/// using secure storage, allowing the app to remember language preferences
/// between sessions.
@lazySingleton
class LocaleService {
  /// Creates a new instance of [LocaleService].
  ///
  /// The storage dependency is injected and used for
  /// persistent storage of locale preferences.
  const LocaleService(this._secureStorageService);

  final ISecureStorageService _secureStorageService;
  static const String _localeKey = 'app_locale';

  /// Saves the current locale to secure storage.
  ///
  /// This persists the user's language preference between app sessions.
  Future<void> saveLocale(final AppLocale locale) async {
    await _secureStorageService.write(_localeKey, locale.languageCode);
  }

  /// Loads the saved locale from secure storage.
  ///
  /// Returns null if no locale has been saved previously.
  Future<AppLocale?> getSavedLocale() async {
    final String? savedLocaleCode = await _secureStorageService.read(
      _localeKey,
    );
    if (savedLocaleCode == null) {
      return null;
    }

    return AppLocale.values.firstWhere(
      (final locale) => locale.languageCode == savedLocaleCode,
      orElse: () => AppLocale.en,
    );
  }

  /// Clears the saved locale from secure storage.
  Future<void> clearSavedLocale() async {
    await _secureStorageService.delete(_localeKey);
  }
}
