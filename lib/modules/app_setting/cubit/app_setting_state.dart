part of 'app_setting_cubit.dart';

class AppSettingState extends Equatable {
  const AppSettingState({this.showOnboardingAtAppOpen = true});

  final bool showOnboardingAtAppOpen;

  AppSettingState copyWith({bool? showOnboardingAtAppOpen}) => AppSettingState(
    showOnboardingAtAppOpen:
        showOnboardingAtAppOpen ?? this.showOnboardingAtAppOpen,
  );

  Map<String, dynamic> toJson() => {
    'showOnboardingAtAppOpen': showOnboardingAtAppOpen,
  };

  factory AppSettingState.fromJson(Map<String, dynamic> json) =>
      AppSettingState(
        showOnboardingAtAppOpen:
            json['showOnboardingAtAppOpen'] as bool? ?? true,
      );

  @override
  List<Object?> get props => [showOnboardingAtAppOpen];
}
