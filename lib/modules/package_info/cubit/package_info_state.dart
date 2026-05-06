part of 'package_info_cubit.dart';

class PackageInfoState extends Equatable {
  const PackageInfoState({this.packageInfo});

  final PackageInfo? packageInfo;

  PackageInfoState copyWith({PackageInfo? packageInfo}) =>
      PackageInfoState(packageInfo: packageInfo ?? this.packageInfo);

  @override
  List<Object?> get props => [packageInfo];
}
