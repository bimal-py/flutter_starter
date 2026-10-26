import 'package:flutter_starter/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Global service locator. Access registered services with `getIt<Type>()`.
final GetIt getIt = GetIt.instance;

/// Run from `main()` BEFORE `runApp` so services are ready when widgets build.
/// Async on purpose: the generated `init` returns a Future as soon as one
/// registration is `@preResolve`, and then neither this nor `main()` changes.
@injectableInit
Future<void> configureDependencyInjection() async {
  // Synchronous until a registration is @preResolve.
  // ignore: await_only_futures
  await getIt.init();
}
