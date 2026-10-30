import 'dart:io';

import 'package:flutter_starter/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every error becomes a message a person can read', () {
    expect(
      AppErrorHandler.getErrorMessage(const SocketException('offline')),
      AppErrorStrings.noInternetConnection,
    );
    expect(
      AppErrorHandler.getErrorMessage(const AppException(message: 'Too late')),
      'Too late',
    );
    expect(
      AppErrorHandler.getErrorMessage(StateError('bug')),
      AppErrorStrings.somethingWentWrong,
    );
  });
}
