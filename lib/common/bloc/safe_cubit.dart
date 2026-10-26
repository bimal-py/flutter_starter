import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] whose [emit] does nothing once it is closed, so a reply that
/// lands after the user left the screen can't crash the app. Blocs don't
/// need this: their `Emitter` is cancelled on close.
abstract class SafeCubit<State> extends Cubit<State> {
  SafeCubit(super.initialState);

  @override
  void emit(State state) {
    if (isClosed) return;
    super.emit(state);
  }
}
