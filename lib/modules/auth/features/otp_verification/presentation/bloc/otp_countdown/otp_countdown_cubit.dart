import 'dart:async';

import 'package:flutter_starter/common/common.dart';

/// Seconds left on the emailed code. The server keeps a code until it
/// expires, so Resend unlocks when this reaches 0.
class OtpCountdownCubit extends SafeCubit<int> {
  OtpCountdownCubit({int seconds = 0}) : super(0) {
    start(seconds);
  }

  Timer? _timer;

  bool get canResend => state <= 0;

  void start(int seconds) {
    _timer?.cancel();
    emit(seconds < 0 ? 0 : seconds);
    if (state == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = state - 1;
      if (next <= 0) _timer?.cancel();
      emit(next < 0 ? 0 : next);
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
