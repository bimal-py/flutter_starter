import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'package_info_state.dart';

class PackageInfoCubit extends Cubit<PackageInfoState> {
  PackageInfoCubit() : super(const PackageInfoState());

  Future<void> loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    emit(state.copyWith(packageInfo: packageInfo));
  }
}
