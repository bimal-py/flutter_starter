import 'dart:async';

import 'package:flutter_starter/modules/user/data/mapper/mapper.dart';
import 'package:flutter_starter/modules/user/domain/domain.dart';
import 'package:flutter_starter/modules/user/utils/storage_helper/storage_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocalUserRepository)
class LocalUserRepositoryImpl implements LocalUserRepository {
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  @override
  UserEntity? get user {
    try {
      final raw = Hive.authUserBox.get(AuthUserStorageKeys.user);
      return raw is String && raw.isNotEmpty
          ? UserMapper.fromRawJsonToEntity(raw)
          : null;
    } catch (_) {
      return null; // Unreadable: the next reply from the server replaces it.
    }
  }

  @override
  Stream<UserEntity?> watchUser() async* {
    yield user;
    yield* _controller.stream;
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    if (user == this.user) return;
    await Hive.authUserBox.put(
      AuthUserStorageKeys.user,
      UserMapper.toRawJsonFromEntity(user),
    );
    _controller.add(user);
  }

  @override
  Future<void> clear() async {
    await Hive.authUserBox.delete(AuthUserStorageKeys.user);
    _controller.add(null);
  }
}
