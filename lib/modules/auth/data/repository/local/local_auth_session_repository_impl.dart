import 'dart:async';

import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/auth/data/mapper/mapper.dart';
import 'package:flutter_starter/modules/auth/domain/domain.dart';
import 'package:flutter_starter/modules/auth/utils/utils.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocalAuthSessionRepository)
class LocalAuthSessionRepositoryImpl implements LocalAuthSessionRepository {
  late final Box<dynamic> _box = Hive.authBox;
  final SecureStorageHelper _secure = SecureStorageHelper.instance;
  final StreamController<AuthSessionEntity?> _controller =
      StreamController<AuthSessionEntity?>.broadcast();

  @override
  Future<AuthSessionEntity?> getSession() async {
    final raw = _box.get(AuthStorageKeys.sessionKey);
    if (raw is! String || raw.isEmpty) return null;
    try {
      return AuthSessionMapper.fromRawJsonToEntity(raw);
    } catch (_) {
      await _box.delete(AuthStorageKeys.sessionKey);
      return null;
    }
  }

  @override
  Stream<AuthSessionEntity?> watchSession() async* {
    yield await getSession();
    yield* _controller.stream;
  }

  @override
  Future<void> saveSession(AuthSessionEntity session) async {
    await _box.put(
      AuthStorageKeys.sessionKey,
      AuthSessionMapper.toRawJsonFromEntity(session),
    );
    _controller.add(session);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secure.write(AuthStorageKeys.accessTokenKey, accessToken);
    await _secure.write(AuthStorageKeys.refreshTokenKey, refreshToken);
  }

  @override
  Future<String?> getAccessToken() =>
      _secure.read(AuthStorageKeys.accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _secure.read(AuthStorageKeys.refreshTokenKey);

  @override
  Future<void> clearSession() async {
    await Future.wait([
      _secure.delete(AuthStorageKeys.accessTokenKey),
      _secure.delete(AuthStorageKeys.refreshTokenKey),
    ]);
    await _box.delete(AuthStorageKeys.sessionKey);
    _controller.add(null);
  }

  @override
  String? rememberedEmail() {
    final email = _box.get(AuthStorageKeys.rememberedEmailKey);
    return email is String && email.isNotEmpty ? email : null;
  }

  @override
  Future<void> saveRememberedEmail(String email) =>
      _box.put(AuthStorageKeys.rememberedEmailKey, email);

  @override
  Future<void> clearRememberedEmail() =>
      _box.delete(AuthStorageKeys.rememberedEmailKey);
}
