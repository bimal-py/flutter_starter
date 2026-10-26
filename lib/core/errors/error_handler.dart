import 'dart:io';

import 'package:flutter_starter/core/errors/errors.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static String getErrorMessage(Object error) {
    if (error is SocketException) return AppErrorStrings.noInternetConnection;
    if (error is AppException) return error.message;
    return AppErrorStrings.somethingWentWrong;
  }
}
