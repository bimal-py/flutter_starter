import 'package:flutter_starter/modules/package_info/domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

@LazySingleton(as: RemotePackageInfoRepository)
class RemotePackageInfoRepositoryImpl implements RemotePackageInfoRepository {
  @override
  Future<PackageInfoEntity> getPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    return PackageInfoEntity(
      appName: info.appName,
      packageName: info.packageName,
      version: info.version,
      buildNumber: info.buildNumber,
      buildSignature: info.buildSignature,
    );
  }
}
