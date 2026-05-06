import 'package:flutter_starter/core/utils/constants/app_constants.dart';
import 'package:hive_flutter/hive_flutter.dart';

extension HiveAppBoxExtension on HiveInterface {
  /// Open the shared app-level box. Use `Hive.box(AppConstants.appBoxName)`
  /// after calling this once at startup.
  Future<Box<dynamic>> openAppBox() => Hive.openBox(AppConstants.appBoxName);

  Box<dynamic> get appBox => Hive.box(AppConstants.appBoxName);

  Future<int> clearAppBox() => appBox.clear();
}
