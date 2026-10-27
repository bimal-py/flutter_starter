# Sizing and fonts

Sizes scale from a 425 × 691 design with flutter_scale_kit, text sizes come from the theme, and the font family (with a size multiplier) is chosen per language.
The rule: page insets and gaps from `AppSpacing`, other sizes as `16.w`, `8.h`, `12.r`, text as `context.textTheme.<role>`. No raw `fontSize`, no fixed pixel sizes.

## Where it lives

```
lib/main.dart                                   ScreenSizeGuard > ScaleKitBuilder(designWidth: 425, designHeight: 691)
lib/common/widgets/screen_size_guard.dart       ScreenSizeGuard: never lets a 0 x 0 screen through
lib/app/app_view.dart                           system text scale capped at 1.2
lib/core/theme/spacing/app_spacing.dart         AppSpacing: the gutter and the spacing scale
lib/core/theme/typography/app_text_style.dart   AppTextStyle.applyTo: size, weight, line height per role
lib/core/theme/typography/localized_fonts.dart  LocalizedFonts, AppFont(family:, scale:, fallback:)
pubspec.yaml (flutter: fonts:)                  Inter (100 to 900), NotoSansDevanagari (400 to 700)
assets/fonts/                                   the .ttf files
```

`core.dart` re-exports flutter_scale_kit and the `context.colorScheme` / `context.textTheme` getters (`lib/core/utils/extensions/context_extension.dart`), so `import 'package:flutter_starter/core/core.dart';` brings in every extension below. Colors and component themes: [theme](theme.md).

## How to use

Spacing comes from `AppSpacing` (`lib/core/theme/spacing/`), so every screen has the same side margin and rhythm:

| Token | Value | Use for |
|---|---|---|
| `AppSpacing.gutter` | `16.w` | left and right inset of page content, list rows, fields |
| `AppSpacing.gutterWide` | `24.w` | narrow centred content: error and empty states, dialogs |
| `AppSpacing.xs` / `sm` / `md` / `lg` / `xl` | `4.h` / `8.h` / `12.h` / `16.h` / `24.h` | vertical gaps |
| `AppSpacing.horizontal` | gutter on both sides | a section's padding |
| `AppSpacing.page` | gutter at the sides, `md` top, `xl` bottom | a scrolling page's `ListView` padding |

```dart
ListView(padding: AppSpacing.page, children: [...]);
Padding(padding: AppSpacing.horizontal, child: ...);
```

To change the gutter for the whole app, change `AppSpacing.gutter`; the input fields' side padding (`InputDecorationThemeBuilder`) follows it. Use raw `.w` / `.h` for sizes inside a widget (a card's own padding, an icon box), not for page insets.

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.sm),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: context.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      12.verticalSpace,
      Text('Title', style: context.textTheme.titleMedium),
      Row(children: [Icon(Icons.info_outline, size: 18.r), 8.horizontalSpace]),
    ],
  ),
)
```

| Write | Scales with | Use for |
|---|---|---|
| `16.w` | screen width ÷ 425, capped per device type | horizontal padding, widths |
| `8.h` | screen height ÷ 691, capped per device type | vertical padding, heights |
| `12.r` | a bounded size factor | corner radius, icon size, square boxes |
| `14.sp`, `14.spClamp(12, 16)` | the smaller of the width and height scale, per device type | font sizes, in the theme only |
| `12.verticalSpace`, `8.horizontalSpace` | `12.h`, `8.w` | gaps in a `Column` / `Row` |

Text roles and their base sizes (each clamped to a band around it: 12 to 16 for bodyMedium's 14, and the widest, 28 to 40, for displayLarge's 36): display 36 / 30 / 24, headline 22 / 20 / 18, title 18 / 16 / 14, body 16 / 14 / 12, label 14 / 12 / 11. Pick the role; restyle with `copyWith(fontWeight: ..., color: ...)` when needed.

Fonts per language (`LocalizedFonts.defaults()`):

- Default: `Inter`, with `NotoSansDevanagari` as fallback, so a Nepali name in an English screen uses the bundled font instead of the phone's.
- `ne`, `hi`: `NotoSansDevanagari`, scale 1.10, with `Inter` as fallback.
- `scale` multiplies every size of the text theme, so scripts that look small next to Latin read the same size.
- The language is the app's locale: `lib/app/app_view.dart` resolves the phone's languages against `AppConstants.supportedLocales` (English only, so far) the way `MaterialApp` does, and passes the result to `AppThemeBuilder.compose(locale:)`.

## How to change / extend

**Match your design file**: set `designWidth` / `designHeight` in `lib/main.dart` to the frame size your designer uses.

**Change the app font**

1. Put the `.ttf` files in `assets/fonts/<family>/`.
2. Declare the family and its weights under `flutter: fonts:` in `pubspec.yaml`.
3. In `LocalizedFonts.defaults()`, change `'Inter'` to `'<Family>'`: the `defaultFont` family and the `ne` / `hi` fallbacks.
4. Stop and run the app again (fonts don't hot reload).

**Add a font for a language**

1. Bundle and declare the font as above.
2. Add `'<code>': AppFont(family: '<Family>', scale: 1.1)` to `byLocale` (ISO 639-1 code: `'ne'`, `'hi'`).
3. Add the locale to `AppConstants.supportedLocales`, and give `MaterialApp.router` the `localizationsDelegates` for its translations (`flutter_localizations` for Material's own strings).
4. A language picker in the app: set `MaterialApp.router(locale:)` from its state and pass the same value to `compose(locale:)`.

**Change the text-scale cap**: `.clamp(maxScaleFactor: 1.2)` in the `MaterialApp.router` `builder` of `lib/app/app_view.dart`.

**Restyle a text role everywhere**: edit its entry in `AppTextStyle.applyTo`, not each `Text`.

## Hidden details

- The theme is built above `MaterialApp`, where `Localizations` doesn't exist yet, so `compose` takes the locale as an argument. Without one, it reads `Localizations.maybeLocaleOf(context)`, which works only below `MaterialApp`.
- The theme picks up a change of the phone's language on its next rebuild (a theme change, a resize), not at once. iOS restarts the app on a language change anyway.
- A family in `fallback` that isn't bundled is skipped without a warning, and the phone's own font fills in.
- Fonts declared in `pubspec.yaml` ship in the app whether used or not.
- The system font size applies on top of `.sp`, capped at 1.2 (no lower cap). Don't use `.spf` in styles: it applies the system scale a second time.
- Scaled values are computed when used. Sizes inside `ThemeData` (`48.h` buttons, `12.r` corners, text sizes) are recomputed because the theme watches flutter_scale_kit and rebuilds when the screen size changes by more than 5% (any change on desktop and web).
- The width and height scales are capped per device type, so `.h` rarely follows the screen height. A portrait phone stops at 1.1 when the screen is more than twice as tall as wide (most current phones), else at 1.15: `100.h` is 110 on a 393 × 852 iPhone, not 123. Tablets stop at 1.3 to 1.5.
- In landscape, flutter_scale_kit swaps the design width and height, so sizes don't shrink to the short edge. On phones and tablets it also multiplies sizes and font sizes by 1.2 (`ScaleKitBuilder`'s landscape boosts, on by default): an 820 × 1180 iPad gives `16.w` = 20.8 in portrait, 26.9 in landscape.
- `main.dart` locks phones to portrait. iPad ignores the lock while multitasking is on (Info.plist allows every iPad orientation), and so does Android 16+ on tablets and unfolded foldables (smallest width 600dp and up), because the app targets SDK 36 (`flutter.targetSdkVersion`).
- `ScaleKitBuilder.designType` is accepted but not used yet by flutter_scale_kit 2.0.2.
- **Blank text after the app comes back from the background.** Android reports a 0 × 0 view while the app is in the background (iOS can before the first frame). flutter_scale_kit 2.0.2 turns that into a zero scale and, measuring the next change as a share of a zero width, never recomputes it: every `.sp` stays 0. `ScreenSizeGuard` in `lib/main.dart` passes the last real size down instead, so the scale never sees zero, and builds nothing until the first real size. Keep it above `ScaleKitBuilder`. `test/common/screen_size_guard_test.dart` checks the fix and pins the package's behaviour; when a release fixes it, that test fails and the guard can go.
- `AppTextStyle.applyTo` copies onto Material's text theme, so Material's text colors stay. Building a `TextTheme` from scratch with null colors would lose them.
