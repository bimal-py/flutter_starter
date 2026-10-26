import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/package_info/domain/domain.dart';

part 'package_info_state.dart';

class PackageInfoCubit extends Cubit<PackageInfoState> {
  PackageInfoCubit() : super(const PackageInfoState());

  final GetPackageInfoUseCase _getPackageInfoUseCase =
      getIt<GetPackageInfoUseCase>();

  Future<void> loadPackageInfo() async {
    final entity = await _getPackageInfoUseCase.execute(const NoParams());
    emit(state.copyWith(packageInfo: entity));
  }
}
