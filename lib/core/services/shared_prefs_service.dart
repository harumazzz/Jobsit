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
}

@Singleton(as: IAuthStorageService)
class AuthStorageService implements IAuthStorageService {
  AuthStorageService(this._secureStorageService);

  static const String tokenKey = 'token';
  static const String userIdKey = 'userId';

  final ISecureStorageService _secureStorageService;

  @override
  Future<String?> getToken() async {
    final result = await _secureStorageService.read(AuthStorageService.tokenKey);

    return result;
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorageService.write(AuthStorageService.tokenKey, token);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorageService.delete(AuthStorageService.tokenKey);
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
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();
}
