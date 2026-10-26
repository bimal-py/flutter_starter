import 'package:flutter_starter/common/bloc/bloc.dart';

/// Holds password-field obscure state. Provide it via `BlocProvider` around
/// any form that needs to toggle the eye icon (`AuthPasswordField`, etc.).
class PasswordVisibilityCubit extends SafeCubit<PasswordVisibilityState> {
  PasswordVisibilityCubit()
    : super(const PasswordVisibilityState(isPasswordVisible: false));

  void toggle() => emit(
    PasswordVisibilityState(isPasswordVisible: !state.isPasswordVisible),
  );

  void show() => emit(const PasswordVisibilityState(isPasswordVisible: true));

  void hide() => emit(const PasswordVisibilityState(isPasswordVisible: false));
}

class PasswordVisibilityState {
  const PasswordVisibilityState({required this.isPasswordVisible});

  final bool isPasswordVisible;
}
