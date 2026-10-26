import 'package:flutter_starter/modules/user/utils/storage_helper/storage_helper.dart';
import 'package:hive_flutter/hive_flutter.dart';

// A box of its own, so logging out wipes the person in one go.
extension HiveAuthUserBoxExtension on HiveInterface {
  Future<Box<dynamic>> openAuthUserBox() =>
      Hive.openBox<dynamic>(AuthUserStorageKeys.boxName);

  Box<dynamic> get authUserBox =>
      Hive.box<dynamic>(AuthUserStorageKeys.boxName);

  Future<int> clearAuthUserBox() => authUserBox.clear();
}
