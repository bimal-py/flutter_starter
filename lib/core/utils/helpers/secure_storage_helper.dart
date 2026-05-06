import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter/core/di/injection.dart';

/// Thin wrapper over [FlutterSecureStorage]. Resolve once from DI and reuse.
class SecureStorageHelper {
  SecureStorageHelper._();

  static SecureStorageHelper get instance => _instance;
  static final SecureStorageHelper _instance = SecureStorageHelper._();

  FlutterSecureStorage get _storage => getIt<FlutterSecureStorage>();

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> removeAllData() => _storage.deleteAll();
}
