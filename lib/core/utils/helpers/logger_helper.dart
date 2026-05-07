import 'dart:developer';

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class CustomLogger {
  final String title;
  final LogLevel minLogLevel;

  CustomLogger({this.title = '', this.minLogLevel = LogLevel.debug});

  void d(String message) => _log(LogLevel.debug, message);
  void i(String message) => _log(LogLevel.info, message);
  void w(String message) => _log(LogLevel.warning, message);
  void e(String message) => _log(LogLevel.error, message);

  void _log(LogLevel level, String message) {
    if (level.index < minLogLevel.index) return;
    if (!kDebugMode) return;
    log(_formatMessage(level, message));
  }

  String _formatMessage(LogLevel level, String message) {
    return '===============>>> [${_getLevelPrefix(level)}] $title: $message';
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
    }
  }
}
