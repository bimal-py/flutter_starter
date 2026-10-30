import 'package:flutter_starter/modules/auth/auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // testWidgets runs in fake time: pump(duration) fires the cubit's timer.
  testWidgets('counts down to zero, then Resend unlocks', (tester) async {
    final cubit = OtpCountdownCubit(seconds: 3);
    expect(cubit.state, 3);
    expect(cubit.canResend, isFalse);

    await tester.pump(const Duration(seconds: 1));
    expect(cubit.state, 2);
    await tester.pump(const Duration(seconds: 2));
    expect(cubit.state, 0);
    expect(cubit.canResend, isTrue);

    await tester.pump(const Duration(seconds: 5));
    expect(cubit.state, 0, reason: 'never below zero');

    cubit.start(2);
    expect(cubit.state, 2);
    await cubit.close();
  });
}
