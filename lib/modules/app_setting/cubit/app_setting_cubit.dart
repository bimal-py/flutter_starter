import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

part 'app_setting_state.dart';

@lazySingleton
class AppSettingCubit extends HydratedCubit<AppSettingState> {
  AppSettingCubit() : super(const AppSettingState());

  void markOnboardingSeen() => emit(state.copyWith(hasSeenOnboarding: true));

  void resetOnboarding() => emit(state.copyWith(hasSeenOnboarding: false));

  @override
  AppSettingState fromJson(Map<String, dynamic> json) =>
      AppSettingState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AppSettingState state) => state.toJson();
}
