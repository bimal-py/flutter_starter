import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppNavigatorObserver extends NavigatorObserver {
  void _log(String action, Route<dynamic>? route, Route<dynamic>? previous) {
    if (!kDebugMode) return;
    debugPrint(
      '[Nav] $action: ${route?.settings.name ?? route?.settings.runtimeType} '
      '(prev: ${previous?.settings.name ?? previous?.settings.runtimeType})',
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('push', route, previousRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('pop', route, previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _log('replace', newRoute, oldRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log('remove', route, previousRoute);
}
