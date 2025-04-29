import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

abstract class ISecureStorageService {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

@Singleton(as: ISecureStorageService)
class SecureStorageService implements ISecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    final String? value = await _storage.read(key: key);
    return value;
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}

abstract class IAuthStorageService {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<void> saveUserId(int userId);
  Future<int?> getUserId();
  Future<bool> isTokenExpired();
}

@Singleton(as: IAuthStorageService)
class AuthStorageService implements IAuthStorageService {
  AuthStorageService(this._secureStorageService);

  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';
  static const String tokenTimestampKey = 'tokenTimestamp';

  static const int tokenExpirationDuration = 7 * 24 * 60 * 60 * 1000;

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
  Future<void> saveToken(String token) async {
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
  Future<void> saveUserId(int userId) async {
    await _secureStorageService.write(AuthStorageService.userIdKey, userId.toString());
  }

  @override
  Future<int?> getUserId() async {
    final result = await _secureStorageService.read(AuthStorageService.userIdKey);
    return result != null ? int.tryParse(result) : null;
  }
}

@module
abstract class StorageModule {
  @singleton
  FlutterSecureStorage get secureStorage {
    const androidOption = AndroidOptions(encryptedSharedPreferences: true);
    const iosOption = IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    return const FlutterSecureStorage(aOptions: androidOption, iOptions: iosOption);
  }
}
