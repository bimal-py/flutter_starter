import 'package:flutter_starter/core/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// Global service locator. Access registered services with `getIt<Type>()`.
final GetIt getIt = GetIt.instance;

/// Run from `main()` BEFORE `runApp` so services are ready when widgets build.
@injectableInit
Future<void> configureDependencyInjection() async {
  await getIt.init();
}
