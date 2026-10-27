# Mobile ads

Google AdMob ads: banner, native template, interstitial, rewarded, rewarded interstitial and app-open, each with its own cubit. It also has house ads that promote your other apps, and an `AdsController` switch you can tie to an ad-free subscription. `MobileAdsInitializer` asks for UMP consent and the iOS tracking permission before it starts the SDK. Keep the module if the app makes money from ads or promotes your other apps. Otherwise remove it.

## What it provides

Paths are under `lib/modules/mobile_ads/`.

- `MobileAdsInitializer` (`utils/helper/`): `MobileAdsInitializer.instance.init()` runs the UMP consent form, then the ATT prompt, then `MobileAds.instance.initialize()`. `lib/main.dart` calls it once.
- `AdsController` (`utils/helper/`): `AdsController.instance.shouldShow({forceShow})`. It has an `enabled` kill switch and an `adsRemoved` hook for entitlements, and it is a `ChangeNotifier`.
- `BannerAdSlot` (`features/banner_ad/`): a banner you drop in. It creates its own `BannerAdCubit`.
- `BannerAdCubit` and `BannerAdFrame`: `load({width})` loads a large anchored adaptive banner. `BannerAdFrame` draws a loaded `BannerAd` at its own size.
- `NativeTemplateAdSlot` and `NativeTemplateAdCubit` (`features/native_ad/features/native_templates_ad/`): Google's small or medium native template. The slot needs a cubit provided above it. `NativeTemplateAdFrame` draws a loaded `NativeAd`.
- `InterstitialAdCubit`, `RewardedAdCubit`, `RewardedInterstitialAdCubit`: `load()`, `showAd(...)` and `isAdReady`. They load the next ad after each show and retry failed loads.
- `AppOpenAdCubit` (`features/app_open_ad/`): `load()`, `listenToAppStateChanges()`, `showAd()` and `isAdReady`. `listenToAppStateChanges()` calls `showAd()` each time the app comes back to the foreground.
- House ads (`features/self_promotion/`):
  - `SelfPromotionBanner` and `SelfPromotionNativeCard` show one app you pass in.
  - `SelfPromotionBannerAd` and `SelfPromotionNativeAd` show a random app.
  - `<App>BannerAd` and `<App>NativeAd` show one fixed app (`CallbreakBannerAd`, `TriadNativeAd`, …).
  - `SelfPromotionApps` is the list of apps (each a `SelfPromotionAppEntity`), `SelfPromotionHelper` has `randomApp()` and `open(app)`, and `SelfPromotionAdBadge` is the "Ad" chip.
- `AppOpenAdHelper`, `BannerAdHelper`, `InterstitialAdHelper`, `NativeAdHelper`, `RewardedAdHelper`, `RewardedInterstitialAdHelper`: each `adUnitId` reads its ad unit ID from `.env`.
- `features/native_ad/features/custom_native_ad/`: an empty placeholder for a native ad layout of your own.

## Depends on

- No other module. From `core` it uses `EnvHelper`, `AppLoadingState`, `context.colorScheme` / `context.textTheme` and flutter_scale_kit. From `common` it uses `SafeCubit`.
- Packages that only this module uses: `google_mobile_ads` and `app_tracking_transparency`. The house ads also use `url_launcher`, but core's `UrlHelper` needs it too.
- Assets: the five logos in `assets/images/ads/`, listed in `pubspec.yaml` under `flutter: assets:`.
- `android/app/src/main/AndroidManifest.xml`:
  - the `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" …/>` entry inside `<application>`, which ships with Google's test App ID;
  - `<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>`.
- `ios/Runner/Info.plist`:
  - `GADApplicationIdentifier` (Google's test App ID);
  - `NSUserTrackingUsageDescription` (the text on the ATT prompt);
  - `SKAdNetworkItems` (50 IDs).
- `.env` (template in `.env_example`): 24 keys named `{DEV,PROD}_{ANDROID,IOS}_{APP_OPEN,BANNER,INTERSTITIAL,REWARDED,REWARDED_INTERSTITIAL,NATIVE}_AD_UNIT_ID`.

## Setup

1. **Ad unit IDs.** Copy the "Google Mobile Ads" section of `.env_example` into `.env` and fill it in. Debug builds read the `DEV_*` keys. Profile and release builds read the `PROD_*` keys. For `DEV_*`, use Google's demo ad units:

   | Format | Android | iOS |
   |---|---|---|
   | App open | `ca-app-pub-3940256099942544/9257395921` | `ca-app-pub-3940256099942544/5575463023` |
   | Banner (adaptive) | `ca-app-pub-3940256099942544/9214589741` | `ca-app-pub-3940256099942544/2435281174` |
   | Interstitial | `ca-app-pub-3940256099942544/1033173712` | `ca-app-pub-3940256099942544/4411468910` |
   | Rewarded | `ca-app-pub-3940256099942544/5224354917` | `ca-app-pub-3940256099942544/1712485313` |
   | Rewarded interstitial | `ca-app-pub-3940256099942544/5354046379` | `ca-app-pub-3940256099942544/6978759866` |
   | Native | `ca-app-pub-3940256099942544/2247696110` | `ca-app-pub-3940256099942544/3986624511` |

   These come from Google's test ad pages for [Android](https://developers.google.com/admob/android/test-ads) and [iOS](https://developers.google.com/admob/ios/test-ads).
2. **AdMob App IDs.** Before release, put your App IDs from AdMob in two places: the `com.google.android.gms.ads.APPLICATION_ID` value in `AndroidManifest.xml`, and `GADApplicationIdentifier` in `Info.plist`. Don't leave either one empty: the comments in those files warn that the SDK crashes at startup without it.
3. **ATT (iOS).** Write your own `NSUserTrackingUsageDescription` text in `Info.plist`. Keep `SKAdNetworkItems` up to date with [Google's list](https://developers.google.com/admob/ios/3p-skadnetworks). You don't need to call anything: `MobileAdsInitializer` shows the prompt.
4. **UMP consent.** In AdMob, under Privacy & messaging, publish a GDPR message. You can also publish an IDFA explainer, which iOS users then see before the ATT prompt. Until a message is published, no form shows and the SDK starts anyway. To test the form from outside the EEA, pass `ConsentRequestParameters(consentDebugSettings: ConsentDebugSettings(debugGeography: DebugGeography.debugGeographyEea, testIdentifiers: ['<device id>']))` in `MobileAdsInitializer._gatherConsent`. Take it out again before release.

`lib/main.dart` already starts the SDK after the first frame, so there is nothing else to wire.

## Use

```dart
// Banner: the slot loads and disposes its own ad.
const BannerAdSlot();

// Full-width banner: give the cubit the width yourself.
final width = MediaQuery.sizeOf(context).width.truncate();
BlocProvider(
  create: (_) => BannerAdCubit()..load(width: width),
  child: BlocBuilder<BannerAdCubit, BannerAdState>(
    builder: (context, state) {
      final ad = state.bannerAd;
      if (!state.loadingState.isSuccess || ad == null) {
        return const SelfPromotionBannerAd(); // house ad until AdMob fills
      }
      return BannerAdFrame(bannerAd: ad);
    },
  ),
);
```

```dart
// Interstitial: provide the cubit above the screens that use it, and load early.
BlocProvider(create: (_) => InterstitialAdCubit()..load(), child: child);

// onAdClosed also runs right away when no ad is loaded, so the flow goes on.
context.read<InterstitialAdCubit>().showAd(
  onAdClosed: () => context.pushNamed(Routes.settings.name),
);
```

```dart
// Rewarded (RewardedInterstitialAdCubit has the same API).
BlocProvider(create: (_) => RewardedAdCubit()..load(), child: child);

final cubit = context.read<RewardedAdCubit>();
if (cubit.isAdReady) {
  cubit.showAd(
    onRewarded: (reward) => unlockHint(), // reward.amount, reward.type
    onClosed: () {},
  );
}
```

```dart
// Native template: one cubit per slot, under a bounded height.
ConstrainedBox(
  constraints: const BoxConstraints(maxHeight: 400), // 200 for small
  child: BlocProvider(
    create: (_) => NativeTemplateAdCubit(),
    child: const NativeTemplateAdSlot(templateType: TemplateType.medium),
  ),
);
```

```dart
// App open: add this to the providers in lib/app/global_bloc_config.dart.
BlocProvider<AppOpenAdCubit>(
  lazy: false, // nothing reads it, so a lazy provider would never start
  create: (_) => AppOpenAdCubit()
    ..load()
    ..listenToAppStateChanges(),
),
```

```dart
// House ads.
const CallbreakBannerAd(); // one fixed app
const SelfPromotionBannerAd(height: 64); // a random app, picked once
const SelfPromotionNativeAd(); // grid-card shape; needs a bounded height
```

```dart
// AdsController: gate each slot. The builder runs again when the controller notifies.
ListenableBuilder(
  listenable: AdsController.instance,
  builder: (context, _) => AdsController.instance.shouldShow()
      ? const BannerAdSlot()
      : const SizedBox.shrink(),
);

// Full-screen ads: skip the ad, not the flow.
if (AdsController.instance.shouldShow()) {
  context.read<InterstitialAdCubit>().showAd(onAdClosed: next);
} else {
  next();
}

// Subscription-ready: add the entitlement inside AdsController,
// because notifyListeners is protected.
bool _isPremium = false;
set isPremium(bool value) {
  if (_isPremium == value) return;
  _isPremium = value;
  notifyListeners();
}

bool get adsRemoved => _isPremium; // replaces `=> false`

// From your purchase code:
AdsController.instance.isPremium = true;
```

## Remove

1. Delete `lib/modules/mobile_ads/`.
2. In `lib/main.dart`, delete:
   - `import 'package:flutter_starter/modules/mobile_ads/mobile_ads.dart';`;
   - the `// Optional. Remove with lib/modules/mobile_ads/.` comment with the three comment lines under it, and the `WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(MobileAdsInitializer.instance.init()));` call they describe;
   - `import 'dart:async';`, because `unawaited` was the only thing that used it.
3. Find anything else that uses the module, such as a provider you added in `lib/app/global_bloc_config.dart` or a slot in a screen: `grep -rn "modules/mobile_ads" lib test`. In the starter as shipped, `lib/main.dart` is the only one.
4. In `pubspec.yaml`, remove `google_mobile_ads: ^9.2.0` and `app_tracking_transparency: ^2.0.6` with their comment lines, and `- assets/images/ads/` under `flutter: assets:`. Then delete the `assets/images/ads/` folder. Keep `url_launcher`, because core uses it.
5. In `android/app/src/main/AndroidManifest.xml`, remove the "AdMob App ID" comment and the `com.google.android.gms.ads.APPLICATION_ID` `<meta-data>` under it. Also remove `<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>` unless something else in the app needs the advertising ID.
6. In `ios/Runner/Info.plist`, remove `GADApplicationIdentifier`, `NSUserTrackingUsageDescription` and `SKAdNetworkItems`, with the comment above each.
7. In `.env` and `.env_example`, remove the "Google Mobile Ads" section (the 24 `*_AD_UNIT_ID` keys).
8. Run `flutter pub get`, `dart run build_runner build` and `flutter analyze`. The module registers nothing with get_it, so `injection.config.dart` should not change.

## Hidden details

- **Startup order.** `main.dart` starts `MobileAdsInitializer.instance.init()` after the first frame and doesn't wait for it, because the consent form and the ATT prompt don't show unless the app is active. Inside `init()`, the steps run in this order:
  1. The UMP consent update, plus the form if UMP says one is needed.
  2. The ATT prompt, on iOS only, and only while the status is "not determined". It waits 200 ms first so the consent form can finish closing.
  3. `MobileAds.instance.initialize()`.
- **Failed startup.** Every error in `init()` is swallowed, and the app runs without ads. A failed run leaves the initializer unmarked, so calling `init()` again would retry, but nothing calls it again.
- **Ads can load before consent.** The ad cubits don't wait for `init()`, and nothing checks `ConsentInformation.instance.canRequestAds()`. A cubit created on the first screen requests ads before the user answers the consent form. If you serve users in the EEA, create ad cubits later or check `canRequestAds()` first.
- **No privacy options entry point.** GDPR users must be able to change their choice later, and the module has no screen or tile for that. Add a settings tile that calls `ConsentForm.showPrivacyOptionsForm(...)` when `await ConsentInformation.instance.getPrivacyOptionsRequirementStatus()` is `PrivacyOptionsRequirementStatus.required`.
- **DEV or PROD keys.** The helpers choose with `kReleaseMode`, like `EnvConfig.authKey`: release builds use the `PROD_*` IDs, debug and profile builds the `DEV_*` ones. A key that is missing from `.env` reads as `''`, so the SDK gets an empty ad unit ID.
- **Android and iOS only.** On web and desktop the helpers throw an `UnsupportedError`. Keep ad slots and cubits out of those builds.
- **Retries.** When a banner, native, interstitial, rewarded or rewarded interstitial ad fails to load, the cubit tries again after 5 s, then 30 s, then 60 s, and then stops. A successful load resets the count. Calling `load()` starts the retries over; for the banner it also disposes the banner on screen first. App-open ads don't retry: the next return to the foreground loads one.
- **After a show.** Full-screen ads load the next ad on their own once one closes or fails to show. When nothing is loaded, `showAd` only runs `onAdClosed` / `onClosed`. It doesn't start a load.
- **Interstitial details.** Interstitials show in immersive mode. `InterstitialAdStatus.showing` is never emitted. The rewarded cubits emit `showing` when `showAd` shows an ad, and the app-open cubit emits it once the ad is on screen.
- **App-open ads.** One that loaded more than 4 hours ago (`AppOpenAdConstants.maxCacheDuration`) isn't shown: `showAd` loads a new one instead, so that return to the app shows nothing. The first launch shows no app-open ad; Google suggests a loading screen if you want one on cold start.
- **Banner size.** `BannerAdSlot` asks for a large anchored adaptive banner for a width of 320 dp (`AdSize.banner.width`), not the screen width. While loading, or after a failure, it holds 50 dp of space. The loaded banner can be taller than that.
- **Native template height.** `AdWidget` is a platform view, and Flutter makes a platform view as big as its constraints allow. Put `NativeTemplateAdSlot` under a bounded height, or the layout fails once the ad loads in a `Column` or `ListView`. Google suggests 90–200 dp for the small template and 320–400 dp for the medium one. Ad sizes are dp from the SDK, so they aren't scaled with flutter_scale_kit.
- **One cubit per native slot.** `AdWidget` throws if the same ad is already in the tree, and the slot calls `load` again in `initState` each time it mounts.
- **AdsController.** No slot or cubit reads `AdsController`, so gating it is your job. `shouldShow(forceShow: true)` always returns true; use it for rewarded ads that unlock a feature, so a subscription doesn't take those away.
- **After close.** The cubits extend `SafeCubit`, so an emit after `close()` does nothing. An ad that finishes loading after close is disposed, and a failure after close schedules no retry.
- **House ad links and layout.** A tap opens the app's download page outside the app (`LaunchMode.externalApplication`), and a malformed URL does nothing. `SelfPromotionNativeCard` gives its tagline the space left over (`Expanded`), so it needs a bounded height, like a grid cell. `SelfPromotionBanner` is `height.r` tall (64 by default).
- **House ad colours.** House ads draw white text on the app's brand colour, so choose dark brand colours.
- **The app list.** `SelfPromotionApps` lists the starter author's own apps, so replace it with yours. `randomApp()` picks from `SelfPromotionApps.all`. To keep an app (for example, the one you are building) out of the random picks, remove it from `all`.
- **Testing.** Clicking your own live ads can get your AdMob account flagged. Use the demo ad units, or register test devices. Emulators and simulators count as test devices automatically.
- **One system dialog at a time.** iOS shows only one system dialog at a time. The ATT plugin's README warns that a notification permission prompt at launch can cancel the ATT prompt. The starter doesn't ask for notification permission at launch.
- **`error` in the ad states** holds the SDK's error message, for logs. It isn't shown to users.
