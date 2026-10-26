# Website view

An in-app browser screen for one URL, built on `flutter_inappwebview`. It shows the page title and a load progress bar, and it handles back, mail, phone and SMS links, and Android backgrounding. Keep it to show web pages (terms, privacy, help) without leaving the app.

## What it provides

- `WebsiteViewScreen(url:)`: the screen the router builds. It builds `WebsiteView`.
- `WebsiteView`: the stateful page: the app bar with title and progress bar, and the `InAppWebView`.

## Depends on

- Other modules: none.
- Packages only this module uses: `flutter_inappwebview`.
- Shared packages: `url_launcher` (core's `UrlHelper` uses it too) and `go_router`.
- Native config: Android needs the `INTERNET` permission, which is already in `android/app/src/main/AndroidManifest.xml`. iOS needs nothing.

## Setup

Nothing to set up.

## Use

The route is `Routes.websiteView` (`/dashboard/website-view`) in `lib/core/router/routes.dart`. Pass the URL as `extra`:

```dart
context.pushNamed(Routes.websiteView.name, extra: AppUrls.privacyPolicy);
```

The "Open website" card on the home screen opens `AppUrls.demoSite` this way.

## Remove

1. Delete `lib/modules/website_view/`.
2. In `lib/core/router/app_router.dart`, delete `import 'package:flutter_starter/modules/website_view/website_view.dart';` and the `GoRoute` for `Routes.websiteView`.
3. In `lib/core/router/routes.dart`, delete `websiteView(name: 'website-view', path: 'website-view');` and make the entry above it end with `;`.
4. In `lib/modules/home/presentation/views/home_screen.dart`, delete the `HomeFeatureCard` with `label: HomeStrings.openWebsite`. `AppUrls.demoSite` and `HomeStrings.openWebsite` are then unused; delete them if you like.
5. In `pubspec.yaml`, delete `flutter_inappwebview`. Keep `url_launcher`: core's `UrlHelper` uses it.
6. Run `flutter pub get`, `dart run build_runner build` and `flutter analyze`.

## Hidden details

- The URL travels in `extra`, not in the path. The router passes `''` when `extra` is not a `String`, so a deep link to `/dashboard/website-view` has no page to load.
- The app bar shows the URL until the page reports its title.
- Back, from the app bar arrow or the system, goes back in the page's history first and closes the screen only when there is none. Because the screen handles the pop itself (`PopScope(canPop: false)`), the iOS swipe-back gesture is off here.
- Only `mailto:`, `tel:` and `sms:` links leave the webview, opened with `LaunchMode.externalApplication`. Nothing tells the user if that launch fails. Other schemes stay in the webview; add them to `_isExternalScheme` if an app should open them.
- `target="_blank"` links load in the same webview (`supportMultipleWindows: false`).
- JavaScript and DOM storage are on. Debug builds can be inspected from desktop dev tools (`isInspectable: kDebugMode`).
- On Android, going to the background pauses the page and its timers, and any other lifecycle change resumes them. `pauseTimers()` is app-wide on Android, so it pauses every webview in the app.
- Plain `http://` pages need `android:usesCleartextTraffic="true"` on Android and an App Transport Security exception on iOS. The starter sets neither.
- The progress bar shows while a load is below 100%, and comes back for every new page.
