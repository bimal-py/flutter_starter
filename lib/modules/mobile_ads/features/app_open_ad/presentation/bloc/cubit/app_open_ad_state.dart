part of 'app_open_ad_cubit.dart';

enum AppOpenAdStatus { initial, loading, loaded, failed, showing }

class AppOpenAdState extends Equatable {
  final AppOpenAdStatus adStatus;
  final AppOpenAd? appOpenAd;
  final String? error;
  final DateTime? appOpenAdLoadTime;
  final bool isFirstLaunch;

  const AppOpenAdState({
    this.adStatus = AppOpenAdStatus.initial,
    this.appOpenAd,
    this.error,
    this.appOpenAdLoadTime,
    this.isFirstLaunch = true,
  });

  @override
  List<Object?> get props => [
    adStatus,
    appOpenAd,
    error,
    appOpenAdLoadTime,
    isFirstLaunch,
  ];

  AppOpenAdState copyWith({
    AppOpenAdStatus? adStatus,
    AppOpenAd? appOpenAd,
    String? error,
    DateTime? appOpenAdLoadTime,
    bool? isFirstLaunch,
  }) {
    return AppOpenAdState(
      adStatus: adStatus ?? this.adStatus,
      appOpenAd: appOpenAd ?? this.appOpenAd,
      error: error ?? this.error,
      appOpenAdLoadTime: appOpenAdLoadTime ?? this.appOpenAdLoadTime,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}
