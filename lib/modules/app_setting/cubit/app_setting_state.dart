part of 'app_setting_cubit.dart';

class AppSettingState extends Equatable {
  const AppSettingState({this.hasSeenOnboarding = false});

  final bool hasSeenOnboarding;

  AppSettingState copyWith({bool? hasSeenOnboarding}) =>
      AppSettingState(
        hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      );

  Map<String, dynamic> toJson() => {'hasSeenOnboarding': hasSeenOnboarding};

  factory AppSettingState.fromJson(Map<String, dynamic> json) =>
      AppSettingState(
        hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [hasSeenOnboarding];
}
