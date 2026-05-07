import 'package:flutter/material.dart';
import 'package:flutter_starter/core/utils/helpers/helpers.dart';

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver();

  final CustomLogger _log = CustomLogger(title: 'Nav-Observer');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log.i('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _log.i('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    _log.i(
      'didStartUserGesture: ${route.str}, '
      'previousRoute= ${previousRoute?.str}',
    );
  }

  @override
  void didStopUserGesture() => _log.i('didStopUserGesture');
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}
