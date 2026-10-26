# Theme

`lib/core/theme/` turns one brand seed into a Material 3 light and dark `ThemeData`: color scheme, component themes, text styles, and a cubit that remembers the user's choice.
The rule: take colors from `context.colorScheme`. Use `context.customTheme` only for `success`, `warning` and `info`, and add a field there only when no ColorScheme role fits.

## Where it lives

```
lib/core/theme/
├── app_theme_builder.dart   AppThemeBuilder.compose: ThemeSource → {light, dark} ThemeData
├── colors/                  AppColors (seed, accent), BrandPalette (seed → ColorScheme)
├── component_themes/        one builder per Material component (buttons, inputs, cards, ...)
├── cubit/                   ThemeCubit + ThemeState (HydratedCubit: persisted)
├── extension/               CustomThemeExtension: success, warning, info
├── source/                  ThemeSource family, ThemePresets, JSON codec
├── typography/              AppTextStyle, LocalizedFonts, AppFont
└── variant/                 ThemeVariant: light, dark, system, custom
lib/app/app_view.dart        DynamicColorBuilder + MaterialApp.router
lib/app/global_bloc_config.dart   provides ThemeCubit
```

How it fits together:

1. `ThemeCubit` holds `variant` (brightness mode), `developerSource` (what you ship; by default a `SeedOnlySource` of `AppColors.seed` and `accent`) and `userOverride` (what the user picked). `state.effectiveSource` is the override, else the developer source.
2. `StarterAppView` wraps `MaterialApp.router` in `DynamicColorBuilder` and calls `AppThemeBuilder.compose` on every theme change.
3. `compose` gets a `ColorScheme` pair from `BrandPalette` (built on `material_color_utilities`, like `ColorScheme.fromSeed`) or from the device, then `_buildOne` adds the text theme, the component themes and the `CustomThemeExtension`.

| Source | Renders | Survives a restart |
|---|---|---|
| `SeedOnlySource(seed:, accent:)` | the palette of one seed (default) | yes |
| `SeedWithOverridesSource` | a seed, then per-role overrides (`{'tertiary': Color(...)}`) | yes |
| `FullCustomSource` | your own schemes, extension, `TextTheme`, font family | no |
| `DynamicDeviceSource(fallbackSeed:)` | wallpaper colors (Android 12+), else the fallback seed | yes |
| `FromImageSource(imageRef:, fallbackSeed:)` | the fallback seed until the image's dominant color is found | yes |

## How to use

```dart
// ColorScheme first.
Container(color: context.colorScheme.primaryContainer);
Text('Saved', style: context.textTheme.titleMedium);

// Only success / warning / info.
Icon(Icons.check_circle, color: context.customTheme.success);

// Brightness mode and user overrides.
final cubit = context.read<ThemeCubit>();
cubit.setVariant(ThemeVariant.dark); // light / dark / system
cubit.setUserSeed(const Color(0xFF006BA6));
cubit.clearUserOverride(); // back to the developer source
```

| You want | Use |
|---|---|
| Brand accent | `tertiary`, `tertiaryContainer`, `onTertiaryContainer` |
| Card, dialog, sheet surface | `surfaceContainerLow`, `surfaceContainerHigh` |
| Borders, dividers | `outlineVariant`, `outline` |
| Failure | `error`, `errorContainer`, `onErrorContainer` |

Text: use `context.textTheme` roles. `AppTextStyle.applyTo` sets size, weight and line height for all 15 roles and keeps Material's colors. Fonts and per-language scale: [sizing and fonts](sizing_and_fonts.md).

Theme playground: Settings → "Customize theme" (`ThemePlaygroundScreen`, route `Routes.themePlayground`, in the [settings module](../modules/settings.md)). The user picks a brightness mode, a preset, a seed, device colors or a photo. It writes only `variant` and `userOverride`; "Reset" calls `clearUserOverride()`.

## How to change / extend

**Change the brand colors**

1. Set `AppColors.seed` in `lib/core/theme/colors/app_colors.dart`.
2. To ship device colors instead: `ThemeCubit(developerSource: const DynamicDeviceSource(fallbackSeed: AppColors.seed))` in `global_bloc_config.dart`.
3. Clear the app's data (or reinstall) on devices that already ran the app. The stored developer source wins over the code (see Hidden details).
4. Check light and dark in the playground.

**Add a preset**

1. Call `ThemePresets.register` in `main()` before `runApp`. It replaces the list (Christmas, Ocean, Sunset, Forest, Lavender, Midnight), so spread `ThemePresets.all` to keep them:

   ```dart
   ThemePresets.register([
     ...ThemePresets.all,
     const ThemePreset(
       id: 'mint',
       label: 'Mint',
       swatch: Color(0xFF00A86B),
       source: SeedOnlySource(seed: Color(0xFF00A86B)),
     ),
   ]);
   ```

2. The playground lists it; tapping it calls `applyCustomSource(preset.source)`.

**Add a component theme**

1. Create `lib/core/theme/component_themes/chip_theme.dart`:

   ```dart
   class ChipThemeBuilder {
     ChipThemeBuilder._();

     static ChipThemeData build({
       required ColorScheme colorScheme,
       required TextTheme textTheme,
     }) {
       return ChipThemeData(
         backgroundColor: colorScheme.surfaceContainerLow,
         labelStyle: textTheme.labelMedium,
         side: BorderSide(color: colorScheme.outlineVariant),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
       );
     }
   }
   ```

2. Export it from `component_themes.dart`.
3. Pass it in `AppThemeBuilder._buildOne`: `chipTheme: ChipThemeBuilder.build(colorScheme: scheme, textTheme: textTheme)`.
4. Colors only from `colorScheme`, sizes from flutter_scale_kit: then it follows every source and both modes. Don't wrap a Material widget just to style it.

**Add a `CustomThemeExtension` field** (only when no ColorScheme role fits)

1. Add the field and its `required` constructor parameter.
2. Give it a value in `lightDefault()` and `darkDefault()`.
3. Add it to `copyWith` and `lerp`.
4. Read it with `context.customTheme.<field>`.

**Use your own success / warning / info colors**: pass an `extensionBuilder` in `global_bloc_config.dart`, so they apply under every source:

```dart
BlocProvider<ThemeCubit>(
  create: (_) => ThemeCubit(
    extensionBuilder: (scheme, brightness) =>
        (brightness == Brightness.dark
                ? CustomThemeExtension.darkDefault()
                : CustomThemeExtension.lightDefault())
            .copyWith(success: const Color(0xFF00875A)),
  ),
),
```

## Hidden details

- Only the variant and the user's override are saved (`theme_state.dart`). The developer source always comes from code, so a new `AppColors.seed` or `ThemeCubit(developerSource:)` reaches existing installs on their next start. The saved state sits under the fixed key `ThemeCubit` (`storagePrefix`), so obfuscated builds keep it.
- `accent` reaches no color role. `BrandPalette` builds every role, tertiary too, from `seed`. Only `BrandPalette.harmonizedAccent` reads `accent`, and nothing calls it. For a brand accent, override `'tertiary'` (and its `on`/`container` roles) with `SeedWithOverridesSource`.
- Override keys are `ColorScheme` field names. Unknown keys are ignored without a warning; `surfaceDim` and `surfaceBright` can't be overridden.
- A `FullCustomSource` saves only its kind, so it can't come back: after a restart the override is dropped and the developer source shows.
- `ThemeVariant.custom('amoled', brightness: Brightness.dark)` is saved as its id plus its brightness and comes back the same. What `amoled` means is up to your source layer.
- Device colors come from the wallpaper on Android 12+ (and from the accent color on desktop). On iOS and older Android, `DynamicDeviceSource` uses its fallback seed. `DynamicColorBuilder` always runs, but its schemes are read only for that source.
- Picking a photo: the cubit samples 1 pixel in 16, keeps the best-scored color and replaces the override with a `SeedOnlySource`. If that fails the fallback seed stays. `NetworkImageRef` is not extracted.
- `toggle()` cycles light → dark → system.
- Sizes in the theme (`48.h` buttons, `12.r` corners) are computed when it is built. `ResponsiveThemeData.create` watches flutter_scale_kit, so the theme rebuilds when the screen size changes.
- One status-bar style for the app, set in `app_view.dart` from the app bar theme or the brightness. Screens don't set their own.
- `AppText` and the deprecated `AppTextScale` are kept for compatibility. Use `context.textTheme` styles.
