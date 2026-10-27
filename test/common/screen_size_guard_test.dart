import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  const real = Size(1080, 2160);

  Future<void> background(WidgetTester tester) async {
    // Android reports a 0 x 0 view while the app is in the background.
    tester.view.physicalSize = Size.zero;
    await tester.pump();
    tester.view.physicalSize = real;
    await tester.pump();
    await tester.pump();
  }

  testWidgets('with the guard, they come back and the app keeps its state', (
    tester,
  ) async {
    tester.view
      ..physicalSize = real
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ScreenSizeGuard(
        child: ScaleKitBuilder(
          designWidth: 425,
          designHeight: 691,
          child: _Counter(),
        ),
      ),
    );
    await tester.pump();
    final before = 16.sp;
    expect(before, greaterThan(0));
    final counter = tester.state<_CounterState>(find.byType(_Counter))
      ..taps = 3;

    await background(tester);

    expect(16.sp, closeTo(before, 0.01));
    expect(tester.state<_CounterState>(find.byType(_Counter)), same(counter));
    expect(counter.taps, 3);
  });

  testWidgets('with the guard, nothing is built before the first real size', (
    tester,
  ) async {
    tester.view
      ..physicalSize = real
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    tester.view.physicalSize = Size.zero;
    await tester.pumpWidget(
      const ScreenSizeGuard(
        child: ScaleKitBuilder(
          designWidth: 425,
          designHeight: 691,
          child: _Counter(),
        ),
      ),
    );
    expect(find.byType(_Counter), findsNothing);

    tester.view.physicalSize = real;
    await tester.pump();
    await tester.pump();
    expect(find.byType(_Counter), findsOneWidget);
    expect(16.sp, greaterThan(0));
  });

  // Last: it leaves flutter_scale_kit's singleton stuck at zero.
  testWidgets('without the guard, scaled sizes stay 0 after a 0 x 0 view', (
    tester,
  ) async {
    tester.view
      ..physicalSize = real
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const ScaleKitBuilder(
        designWidth: 425,
        designHeight: 691,
        child: SizedBox(),
      ),
    );
    await tester.pump();
    expect(16.sp, greaterThan(0));

    await background(tester);

    // The flutter_scale_kit 2.0.2 behaviour the guard exists for. If this
    // starts failing, the package fixed it and the guard can go.
    expect(16.sp, 0);
  });
}
