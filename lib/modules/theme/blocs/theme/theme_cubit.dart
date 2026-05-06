import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

part 'theme_state.dart';

@lazySingleton
class ThemeCubit extends HydratedCubit<ThemeModeState> {
  ThemeCubit() : super(const ThemeModeState());

  void setMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void toggle() {
    final next = switch (state.themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    setMode(next);
  }

  @override
  ThemeModeState fromJson(Map<String, dynamic> json) =>
      ThemeModeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(ThemeModeState state) => state.toJson();
}
