import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// The zero-size bug as the app meets it: the view itself goes 0 x 0 (not a
/// hand-built MediaQuery) and the text comes from the real theme, which is
/// built once from the scale and must be rebuilt when the scale arrives.
class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> {
  int taps = 0;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text('hello', style: context.textTheme.bodyMedium));
}

Widget _app() => ScaleKitBuilder(
  designWidth: 425,
  designHeight: 691,
  child: Builder(
    builder: (context) {
      final themes = AppThemeBuilder.compose(
        context: context,
        source: const SeedOnlySource(
          seed: AppColors.seed,
          accent: AppColors.accent,
        ),
        fonts: LocalizedFonts.defaults(),
      );
      return MaterialApp(theme: themes.light, home: const _Page());
    },
  ),
);

/// The size the text is really drawn at.
double _drawnFontSize(WidgetTester tester) {
  final paragraph = tester.renderObject<RenderParagraph>(find.text('hello'));
  return paragraph.text.style!.fontSize!;
}

void main() {
  // 430 wide, so the theme's text is about 14. On a 360-wide phone it would
  // sit at the theme's spClamp minimum of 12, which is also what a zero scale
  // gives, and the tests couldn't tell the two apart.
  const phone = Size(1290, 2580);

  void setView(WidgetTester tester, Size physicalSize) {
    tester.view
      ..physicalSize = physicalSize
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  // MaterialApp animates a new theme, so give it time to finish.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  // First: the only test that starts with a ScaleManager that never had a
  // real size, as a process does on a real cold start.
  testWidgets('cold start at 0 x 0 draws the same text as a normal start', (
    tester,
  ) async {
    setView(tester, Size.zero);
    await tester.pumpWidget(_app());
    await tester.pump();

    tester.view.physicalSize = phone;
    await settle(tester);
    final recovered = _drawnFontSize(tester);
    expect(recovered, greaterThan(13));
    expect(16.w, greaterThan(0));
    expect(12.r, greaterThan(0));

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_app());
    await settle(tester);
    expect(_drawnFontSize(tester), closeTo(recovered, 0.01));
  });

  testWidgets('background and back keeps the text and the app state', (
    tester,
  ) async {
    setView(tester, phone);
    await tester.pumpWidget(_app());
    await settle(tester);
    final before = _drawnFontSize(tester);
    final page = tester.state<_PageState>(find.byType(_Page))..taps = 3;

    for (var i = 0; i < 3; i++) {
      tester.view.physicalSize = Size.zero;
      await tester.pump();
      expect(16.sp, greaterThan(0));
      expect(16.w, greaterThan(0));
      expect(_drawnFontSize(tester), closeTo(before, 0.01));

      tester.view.physicalSize = phone;
      await settle(tester);
      expect(_drawnFontSize(tester), closeTo(before, 0.01));
    }

    expect(tester.state<_PageState>(find.byType(_Page)), same(page));
    expect(page.taps, 3);
  });

  testWidgets('returning at a new size scales to the new size', (tester) async {
    const tablet = Size(2460, 3540);
    setView(tester, phone);
    await tester.pumpWidget(_app());
    await settle(tester);
    final onPhone = _drawnFontSize(tester);

    tester.view.physicalSize = Size.zero;
    await tester.pump();
    tester.view.physicalSize = tablet;
    await settle(tester);

    expect(_drawnFontSize(tester), greaterThan(onPhone));
  });

  // Guards the rest of the suite can't reach through a widget, because the
  // builder's own checks stop a bad size first.
  testWidgets('the manager itself refuses a 0 x 0 size and a 0 design', (
    tester,
  ) async {
    setView(tester, phone);
    await tester.pumpWidget(_app());
    await settle(tester);
    final context = tester.element(find.byType(_Page));
    final width = 1.0.sw;

    tester.view.physicalSize = Size.zero;
    await tester.pump();
    ScaleManager.instance.updateFromContext(context);
    expect(ScaleManager.instance.hasValidMetrics, isTrue);
    expect(1.0.sw, closeTo(width, 0.01));

    tester.view.physicalSize = phone;
    await settle(tester);
    final scale = ScaleManager.instance.scaleWidth;
    ScaleManager.instance.init(
      context: context,
      designWidth: 0,
      designHeight: 0,
    );
    expect(ScaleManager.instance.scaleWidth, scale);
    ScaleManager.instance.init(
      context: context,
      designWidth: 425,
      designHeight: 691,
    );
  });

  // The 2.0.2 behaviour the game's older copy lacks, with the documented
  // numbers from doc/core/sizing_and_fonts.md, surviving a 0 x 0 frame.
  testWidgets('an iPad keeps its portrait and landscape sizes', (tester) async {
    const portrait = Size(2460, 3540);
    const landscape = Size(3540, 2460);
    setView(tester, portrait);
    await tester.pumpWidget(_app());
    await settle(tester);
    expect(16.w, closeTo(20.8, 0.1));

    tester.view.physicalSize = landscape;
    await settle(tester);
    expect(16.w, closeTo(26.9, 0.1));

    tester.view.physicalSize = Size.zero;
    await tester.pump();
    tester.view.physicalSize = landscape;
    await settle(tester);
    expect(16.w, closeTo(26.9, 0.1));
  });
}
