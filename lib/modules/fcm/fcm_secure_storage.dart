import 'package:flutter_starter/core/utils/utils.dart';
import 'package:flutter_starter/modules/fcm/fcm_storage_keys.dart';

/// Token-sync + permission-prompt persistence for FCM. Wraps the global
/// SecureStorageHelper so the FCM module owns its keys without re-implementing
/// the storage layer.
class FcmSecureStorage {
  FcmSecureStorage();

  final SecureStorageHelper _storage = SecureStorageHelper.instance;

  Future<bool> shouldSyncToken({
    required String token,
    required String userId,
  }) async {
    final syncedToken = await _storage.read(FcmStorageKeys.syncedFcmToken);
    final syncedUserId = await _storage.read(FcmStorageKeys.syncedFcmUserId);
    return syncedToken != token || syncedUserId != userId;
  }

  Future<void> markTokenSynced({
    required String token,
    required String userId,
  }) async {
    await Future.wait([
      _storage.write(FcmStorageKeys.syncedFcmToken, token),
      _storage.write(FcmStorageKeys.syncedFcmUserId, userId),
    ]);
  }

  Future<void> clearTokenSyncCache() => Future.wait([
        _storage.delete(FcmStorageKeys.syncedFcmToken),
        _storage.delete(FcmStorageKeys.syncedFcmUserId),
      ]);

  Future<bool> wasPermissionPrompted() async =>
      (await _storage.read(FcmStorageKeys.permissionPrompted)) == 'true';

  Future<void> markPermissionPrompted() =>
      _storage.write(FcmStorageKeys.permissionPrompted, 'true');
}
