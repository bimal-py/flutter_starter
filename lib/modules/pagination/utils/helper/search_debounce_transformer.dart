import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

/// How long a paginated list waits after the last keystroke before querying.
const searchDebounceDuration = Duration(milliseconds: 500);

/// Debounce, then restart: while the user is still typing nothing is dispatched,
/// and a new query cancels the in-flight one so only the latest search wins.
/// Give it to a Bloc's search event:
/// ```dart
/// on<NotesSearchChanged>(
///   _onSearchChanged,
///   transformer: debounceRestartable(searchDebounceDuration),
/// );
/// ```
EventTransformer<E> debounceRestartable<E>(Duration duration) =>
    (events, mapper) => events.debounce(duration).switchMap(mapper);
