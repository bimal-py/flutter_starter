import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter/core/core.dart';

/// Shared shape of every paginated list state: a load status plus a flag for
/// the "appending the next page" case.
///
/// Purely additive — the state classes that mix this in already declare both
/// members as `final` fields, so `props`, `==` and `hashCode` are untouched.
mixin PaginatedListState {
  AppLoadingState get loadingState;
  bool get isLoadingMore;
}

extension PaginatedBlocX<E, S extends PaginatedListState> on Bloc<E, S> {
  /// Completes once the bloc has finished settling a refresh — that is, once it
  /// is no longer appending a page and has reached success or failure.
  ///
  /// Pull-to-refresh handlers `await` this so the indicator stays up until
  /// the list has actually reloaded.
  ///
  /// `orElse` returns the current state rather than throwing: without it a bloc
  /// that closes mid-refresh (the user leaves the screen) makes `firstWhere`
  /// complete with a `StateError` out of `onRefresh`.
  Future<void> awaitSettled() => stream
      .firstWhere(
        (s) =>
            !s.isLoadingMore &&
            (s.loadingState == AppLoadingState.success ||
                s.loadingState == AppLoadingState.failure),
        orElse: () => state,
      )
      .then((_) {});
}
