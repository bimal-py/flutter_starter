import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/utils/helpers/helpers.dart';

class AppBlocObserver extends BlocObserver {
  final CustomLogger _log = CustomLogger(title: 'Bloc-Observer');

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _log.i('Event: ${bloc.runtimeType} ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _log.i('Change: ${bloc.runtimeType} $change');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _log.d('Transition: ${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _log.e('Error: ${bloc.runtimeType} $error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
