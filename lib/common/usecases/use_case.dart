import 'dart:async';

/// Base contract for every use case. One verb per class — each [execute]
/// is a single business action the bloc / cubit can invoke. Wrap it with
/// [Injectable] so DI hands the right repository in.
abstract class UseCase<ReturnType, Params> {
  FutureOr<ReturnType> execute(Params params);
}

/// Stream variant — use for live data (auth state, chat messages, …).
abstract class StreamUseCase<ReturnType, Params> {
  Stream<ReturnType> execute(Params params);
}
