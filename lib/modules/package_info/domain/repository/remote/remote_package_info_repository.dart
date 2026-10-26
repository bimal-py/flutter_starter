import 'package:flutter_starter/modules/package_info/domain/entity/entity.dart';

abstract class RemotePackageInfoRepository {
  Future<PackageInfoEntity> getPackageInfo();
}
