import 'package:flutter_starter/modules/app_upgrade/domain/entity/entity.dart';

abstract class RemoteAppUpgradeRepository {
  Future<AppUpgradeInfoEntity?> checkForUpdate();
  Future<void> markVersionIgnored(String version);
  String? getIgnoredVersion();
}
