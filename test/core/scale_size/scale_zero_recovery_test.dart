import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/core/scale_size/scale_size.dart';

/// Regression tests for the zero-scale text collapse.
///
/// `MediaQuery.size` is documented to return `Size.zero` before the native
/// surface reports metrics (cold start) and while the surface is detached
/// (screen off / backgrounded). Feeding that into `ScaleManager` drove
/// `_getScaleLimits`' mobile branch to `effectiveMin = 0`, zeroing every
/// scaled value, and `_checkForChanges`' divide-by-zero guards then made the
/// state absorbing — text stayed invisible until the process restarted.
///
/// Under `flutter_test` `defaultTargetPlatform` is android, i.e. exactly the
/// branch that has no lower bound on `effectiveMin`.
Widget _app(Size size) => MediaQuery(
  data: MediaQueryData(size: size),
  child: ScaleKitBuilder(
    designWidth: 425,
    designHeight: 691,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (_) => Text('x', style: TextStyle(fontSize: 16.sp)),
      ),
    ),
  ),
);

void main() {
  const real = Size(411.4, 866.3);

  testWidgets('cold start: Size.zero then real size recovers', (tester) async {
    await tester.pumpWidget(_app(Size.zero));
    await tester.pump();

    await tester.pumpWidget(_app(real));
    await tester.pump();
    await tester.pump();

    expect(ScaleManager.instance.scaleWidth, greaterThan(0.5));
    expect(16.sp, closeTo(15.8, 0.5));
    // `.sw` reads _screenWidth directly, so it catches a manager that recovered
    // its scale factors but kept a zero viewport.
    expect(1.0.sw, closeTo(411.4, 0.1));
  });

  testWidgets('resume: real -> Size.zero -> real never drops to zero', (
    tester,
  ) async {
    await tester.pumpWidget(_app(real));
    await tester.pump();

    // Screen off / backgrounded: the degenerate size must be ignored outright,
    // not adopted and recovered from.
    await tester.pumpWidget(_app(Size.zero));
    await tester.pump();
    expect(ScaleManager.instance.scaleWidth, greaterThan(0.5));

    await tester.pumpWidget(_app(real));
    await tester.pump();
    await tester.pump();
    expect(16.sp, closeTo(15.8, 0.5));
  });

  testWidgets('deferred init does not serve stale cached values', (
    tester,
  ) async {
    // 360x640 has aspect 0.5625 -> `standard`, so its ScaleValueCache deviceId
    // ("mobile_portrait_standard") collides with the one derived from Size.zero.
    // Without a cache flush on late init, the pre-init 1.0x values survive.
    const smallDevice = Size(360, 640);

    await tester.pumpWidget(_app(Size.zero));
    await tester.pump();

    await tester.pumpWidget(_app(smallDevice));
    await tester.pump();
    await tester.pump();

    // `.sp` goes through ScaleValueCache; getFontSize bypasses it.
    expect(16.sp, closeTo(ScaleManager.instance.getFontSize(16), 0.01));
    expect(16.sp, closeTo(13.55, 0.1));
  });
}
