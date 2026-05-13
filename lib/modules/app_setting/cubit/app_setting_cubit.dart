import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'app_setting_state.dart';

class AppSettingCubit extends HydratedCubit<AppSettingState> {
  AppSettingCubit() : super(const AppSettingState());

  void markOnboardingComplete() =>
      emit(state.copyWith(showOnboardingAtAppOpen: false));

  void requestOnboardingReplay() =>
      emit(state.copyWith(showOnboardingAtAppOpen: true));

  @override
  AppSettingState fromJson(Map<String, dynamic> json) =>
      AppSettingState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AppSettingState state) => state.toJson();
}
