part of 'theme_cubit.dart';

class ThemeModeState extends Equatable {
  const ThemeModeState({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  ThemeModeState copyWith({ThemeMode? themeMode}) =>
      ThemeModeState(themeMode: themeMode ?? this.themeMode);

  Map<String, dynamic> toJson() => {'themeMode': themeMode.name};

  factory ThemeModeState.fromJson(Map<String, dynamic> json) {
    final raw = json['themeMode'] as String?;
    final mode = ThemeMode.values.firstWhere(
      (m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
    return ThemeModeState(themeMode: mode);
  }

  @override
  List<Object?> get props => [themeMode];
}
