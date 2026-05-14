import 'dart:async';
import 'dart:convert';

import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:flutter_starter/core/utils/helpers/secure_storage_helper.dart';
import 'package:flutter_starter/modules/auth/domain/entity/auth_user.dart';
import 'package:flutter_starter/modules/auth/domain/repository/local/user_session_store.dart';
import 'package:flutter_starter/modules/auth/utils/storage_helper/auth_storage_keys.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

/// Default [UserSessionStore]: user JSON in Hive `app_box`, tokens in
/// `flutter_secure_storage`. Both already wired in the starter — no setup.
@LazySingleton(as: UserSessionStore)
class HiveSecureSessionStore implements UserSessionStore {
  HiveSecureSessionStore();

  /// Box / secure-storage are pulled lazily so unit tests can substitute a
  /// different impl of [UserSessionStore] without needing to provide either.
  late final Box<dynamic> _userBox = Hive.box<dynamic>(AppConstants.appBoxName);
  late final SecureStorageHelper _secure = SecureStorageHelper.instance;

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();

  @override
  Future<void> saveUser(AuthUser user) async {
    await _userBox.put(AuthStorageKeys.loggedInUserKey, jsonEncode(user.toJson()));
    _controller.add(user);
  }

  @override
  Future<AuthUser?> getUser() async {
    final raw = _userBox.get(AuthStorageKeys.loggedInUserKey);
    if (raw is! String || raw.isEmpty) return null;
    try {
      return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Drop corrupt payload so the next login can write fresh data.
      await _userBox.delete(AuthStorageKeys.loggedInUserKey);
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    await _userBox.delete(AuthStorageKeys.loggedInUserKey);
    _controller.add(null);
  }

  @override
  Stream<AuthUser?> watchUser() async* {
    yield await getUser();
    yield* _controller.stream;
  }

  @override
  Future<void> saveAccessToken(String token) =>
      _secure.write(AuthStorageKeys.accessTokenKey, token);

  @override
  Future<String?> getAccessToken() =>
      _secure.read(AuthStorageKeys.accessTokenKey);

  @override
  Future<void> clearAccessToken() =>
      _secure.delete(AuthStorageKeys.accessTokenKey);

  @override
  Future<void> saveRefreshToken(String token) =>
      _secure.write(AuthStorageKeys.refreshTokenKey, token);

  @override
  Future<String?> getRefreshToken() =>
      _secure.read(AuthStorageKeys.refreshTokenKey);

  @override
  Future<void> clearRefreshToken() =>
      _secure.delete(AuthStorageKeys.refreshTokenKey);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  @override
  Future<void> saveSession({
    required AuthUser user,
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await saveUser(user);
  }

  @override
  Future<void> clearSession() async {
    await Future.wait([clearAccessToken(), clearRefreshToken()]);
    await clearUser();
  }

  Future<void> dispose() => _controller.close();
}
