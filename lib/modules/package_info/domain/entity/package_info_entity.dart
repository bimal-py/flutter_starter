import 'package:equatable/equatable.dart';

class PackageInfoEntity extends Equatable {
  const PackageInfoEntity({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    this.buildSignature = '',
  });

  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;

  @override
  List<Object?> get props => [
    appName,
    packageName,
    version,
    buildNumber,
    buildSignature,
  ];
}
